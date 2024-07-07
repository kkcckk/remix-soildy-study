// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "./interface/IERC1155.sol";
import "./interface/IERC1155Receiver.sol";
import "./interface/IERC1155MetadataURI.sol";
import "./interface/IERC165.sol";
import "./library/String.sol";
import "./library/Address.sol";

/**
    支持一个合约包含多种代币，包含了NFT和FT
    区分NFT和FT，就看对应的代币总量是否是大于1，一般NFT的总量为1，FT的总量会大于1
    在ERC1155中，会使用id来作为代币标识，id是唯一的，并且每一个代币都一个uri地址来存储以及管理元数据信息
*/

contract ERC1155 is IERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;
    using Strings for uint256;

    // token名称
    string public name;
    // token符号
    string public symbol;

    // 余额
    mapping (uint256 => mapping (address => uint256)) private _balances;
    // 授权
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // 构造函数，初始化名称和符号
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 必须要重写165的函数
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId ||
                interfaceId == type(IERC1155MetadataURI).interfaceId ||
                interfaceId == type(IERC165).interfaceId;
    }

    // 查找余额
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        return _balances[id][account];
    }

    // 批量查询余额
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        public
        view
        virtual
        override
        returns (uint256[] memory) {
            // 授权地址列表和id列表的长度要一致
            require(accounts.length == ids.length, "ERC1155, the length of accounts and ids is not equals.");

            // 用来存放余额列表
            uint256[] memory batchBalances = new uint256[](accounts.length);

            // 开始循环查询
            for(uint i = 0; i < accounts.length; i++) {
                batchBalances[i] = balanceOf(accounts[i], ids[i]);
            }

            return batchBalances;
    }

    // 授权
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "Don't approval to yourself.");
        _operatorApprovals[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查询是否授权批量处理权限
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    // 进行转账
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) public {
        // 判断msg.sender和from之间的关系，是否有权限进行操作
        address sender = msg.sender;

        require(sender == from || isApprovedForAll(sender, from), "Access denied.");

        // to地址不能为空
        require(to != address(0), "`to` can't be zero address");

        // 单个转账时，把单个账户和单个金额转换为数组
        (uint256[] memory ids, uint256[] memory amounts) = _asSingletonArrays(id, amount);

        // 开始转账
        _update(from, to, ids, amounts);

        // 进行安全检查
        _doSafeTransferAcceptanceCheck(sender, from, to, id, amount, data);
    }

    // 批量转账
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) public {
        // 判断msg.sender和from之间的关系，是否有权限进行操作
        address sender = msg.sender;

        require(sender == from || isApprovedForAll(sender, from), "Access denied.");

        // to地址不能为空
        require(to != address(0), "`to` can't be zero address");

        // 开始转账
        _update(from, to, ids, amounts);

        // 进行安全检查
        _doSafeBatchTransferAcceptanceCheck(sender, from, to, ids, amounts, data);
    }

    // 进行转账
    function _update(address from, address to, uint256[] memory ids, uint256[] memory amounts) internal {
        // 要求ids和amounts长度一致
        require(ids.length == amounts.length, "The length of ids and amounts is not equal.");

        // 进行转账
        for (uint256 i=0; i < ids.length; i++) {
            // 要转账的代币和金额
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            // 余额必须大于转账的金额
            require(balanceOf(from, id) > amount, "Insufficient token balance");

            // 更新余额
            unchecked {
                _balances[id][from] -= amount;
            }

            _balances[id][to] += amount;

            // 触发事件
            address sender = msg.sender;
            if (ids.length == 1) {
                emit TransferSingle(sender, from, to, id, amount);
            } else {
                emit TransferBatch(sender, from, to, ids, amounts);
            }
        }
    }

    // 铸币
    function _mintSafe(address to, uint256 id, uint256 amount, bytes memory data) internal virtual {
        // 目标地址不能是空
        require(to != address(0), "The `to` address can't be zero address");

        // 铸币的人
        address sender = msg.sender;

        _balances[id][to] += amount;

        // 触发事件
        emit TransferSingle(sender, address(0), to, id, amount);

        // 进行安全检查
        _doSafeTransferAcceptanceCheck(sender, address(0), to, id, amount, data);
    }

    // 进行批量铸币
    function _mintBatchSafe(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        // 目标地址不能是address(0)
        require(to != address(0), "The `to` can't be zero address.");

        // ids的长度和amounts的长度一样
        require(ids.length == amounts.length, "The length of ids and amounts is not equal.");

        // 铸币的人
        address sender = msg.sender;

        // 开始批量铸币
        for (uint256 i = 0; i <= ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        // 触发事件
        emit TransferBatch(sender, address(0), to, ids, amounts);

        // 进行安全检查
        _doSafeBatchTransferAcceptanceCheck(sender, address(0), to, ids, amounts, data);
    }

    // 销毁币和批量销毁币，可以指定数量
    function _burn(address from, uint256 id, uint256 amount) internal virtual {
        // from不能是addres(0)
        require(from != address(0), "The address of `from` can't be zero address.");

        // 调用者
        address sender = msg.sender;

        // 找出余额
        uint256 balanceToken = _balances[id][from];

        // 销毁的数量不能大于余额
        require(amount <= balanceToken, "The burned amount can not exceed the balance of the token.");

        unchecked {
            _balances[id][from] -= amount;
        }

        emit TransferSingle(sender, from, address(0), id, amount);
    }
    
    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        // from不能是addres(0)
        require(from != address(0), "The address of `from` can't be zero address.");

        // 调用者
        address sender = msg.sender;

        // 开始批量销毁币
        for (uint256 i = 0; i < ids.length; i++) {
            // 找出id
            uint256 id = ids[i];

            // 找出销毁的数量
            uint256 amount = amounts[i];
            
            // 找出余额
            uint256 balanceToken = _balances[id][from];

            // 销毁的数量不能大于余额
            require(amount <= balanceToken, "The burned amount can not exceed the balance of the token.");

            unchecked {
                _balances[id][from] = balanceToken - amount;
            }
        }

        // 触发事件
        emit TransferBatch(sender, from, address(0), ids, amounts);
    }
    
    // 返回token URI
    function uri(uint256 id) public view virtual override returns(string memory) {
        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, id.toString())) : "";
    }
    
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    // 检查单个转账
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount, 
        bytes memory data) private {
            if (to.isContract()) {
                try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 retval) {
                    if (retval != IERC1155Receiver.onERC1155Received.selector) {
                        revert("ERC1155: ERC1155Receiver rejected tokens");
                    }
                } catch Error(string memory reason) {
                    revert(reason);
                } catch {
                    revert("ERC1155: The transaction receiver has not implemented the IERC1155Receiver.onErc1155Received function.");
                }
            }
        }

    // 检查批量转账
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data) private {
            if (to.isContract()) {
                try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns(bytes4 retval) {
                    if (IERC1155Receiver.onERC1155BatchReceived.selector != retval) {
                        revert("ERC1155: ERC1155Receiver rejected tokens");
                    }
                } catch Error(string memory reason) {
                    revert(reason);
                } catch {
                    revert("ERC1155: The transaction receiver has not implemented the IERC1155Receiver.onErc1155BatchReceived function.");
                }
            }
        }

    // 将单个值转换为数组
    function _asSingletonArrays(uint256 id, uint256 amount) internal pure returns(uint256[] memory ids, uint256[] memory amounts) {
        assembly {
            // 在evm中，使用0x40位置的值作为起始位置，并更新该值以指向新的空闲内存位置
            ids := mload(0x40)

            // 创建ids数组，长度为1，因为数组的第一个存储位置是存储的数组的长度，第二个位置开始，存储的数组的元素
            mstore(ids, 1)

            // 存入数据，因为只有一个元素，一个元素的长度又是0x20
            mstore(add(ids, 0x20), id)

            amounts := add(ids, 0x40)
            mstore(amounts, 1)
            mstore(add(amounts, 0x20), amount)

            // 更新空闲位置地址值
            mstore(0x40, add(amounts, 0x40))
        }
    }
}