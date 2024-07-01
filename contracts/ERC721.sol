// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IERC165.sol";
import "./interface/IERC721.sol";
import "./interface/IERC721Metadata.sol";
import "./interface/IERC721Receiver.sol";
import "./library/String.sol";

/**
    NFT,相当于游戏中的装备一样，一类装备就是一个NFT，在NFT中，一个tokenId是不能重复的
    一个tokenId就是一件NFT，然后对应一个owner
    一个owner可以有多个NFT，一个tokenId只能对应一个owner
**/
contract ERC721 is IERC721, IERC721Metadata {
    using Strings for uint256;

    // 名称
    string public name;

    // 符合
    string public symbol;

    // tokenId映射到拥有者地址
    // 用tokenId做为键，确保了唯一性
    mapping (uint => address) private _owners;

    // 地址对应的余额,一个tokenId+1
    mapping (address => uint) private _balances;

    // tokenId映射到授权地址
    mapping (uint => address) private _tokenIdApprovals;

    // 批量授权，owner批量授权地址，如果address是批量授权，那bool就是true，如果不是批量授权，那么bool就是false
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // 非法的接收者告警
    error ERC721InvalidReceiver(address receiver);

    // 构造器，初始化NFT的时候需要传入名称和符合,无法修改的，只能在创建的时候输入
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 要进行support判断，判断是否实现了IERC165接口
    function supportsInterface(bytes4 interfaceId) external pure override returns(bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 查询余额
    function balanceOf(address owner) external view override returns(uint256) {
        require(owner != address(0), "owner == ZeroAddress, is invalid");
        return _balances[owner];
    }

    // 查询代币的拥有者
    function ownerOf(uint256 tokenId) external view override returns(address owner) {
        owner = _owners[tokenId];

        // owner不能是address(0)
        require(owner != address(0), "token is not exist");
    }

    // 查询某个地址是否被批量授权了
    function isApprovedForAll(address owner, address operator) external view override returns(bool) {
        return _operatorApprovals[owner][operator];
    }

    // 将调用者的所有代币授权给operator地址
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator]=true;

        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    // 查询某个tokenId的授权地址
    function getApproved(uint tokenId) external view override returns(address) {
        // 首先代币是需要创建了的，即owner有值
        require(_owners[tokenId] != address(0), "token does not exist!!!");
        return _tokenIdApprovals[tokenId];
    }

    // 进行授权
    function approve(address to, uint tokenId) external override {
        /**
            1. 不能给address(0)转账
            2. 判断调用者与tokenId owner的关系，首先从tokenId找出owner
                1). 调用者不能是address(0)，不过调用者是通过msg.sender获取的，不可能是address(0)
                2). 如果调用者不是owner，但是调用者地址被owber批量授权了，说明调用者是有权限处理这个tokenId的，可以进行授权
            3. 最后，判断from和tokenId的上任owner地址是否一致
        */
        
        // 找出代币owner
        address owner = _owners[tokenId];

        // 只有owner才有权限调用approve函数，并且
        require(owner == msg.sender || _operatorApprovals[owner][msg.sender], "invalid call function 'approve'");

        _approve(owner, to, tokenId);
    }

    // 授权操作
    function _approve(address owner, address to, uint tokenId) private {
        _tokenIdApprovals[tokenId]=to;

        // 触发授权事件
        emit Approval(owner, to, tokenId);
    }

    // 查询spender地址是否可以操作tokenId，spender在进行转账的时候就是msg.sender调用者
    function _isApprovedOrOwner(address owner, address spender, uint tokenId) private view returns(bool) {
        return owner == spender || _operatorApprovals[owner][spender] || _tokenIdApprovals[tokenId] == spender;
    }

    // 转账
    function transferFrom(address from, address to, uint tokenId) external override {
        // 做出权限判断
        // 找出owner
        address owner = _owners[tokenId];
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner or approved");

        // 转账操作
        _transfer(owner, from, to, tokenId);
    }

    function _transfer(address owner, address from, address to, uint tokenId) private {
        require(from == owner && to != address(0), "not owner");

        // 原拥有者币的种类的个数-1
        _balances[from] -= 1;

        // 现拥有者币的种类的个数+1
        _balances[to] += 1;

        // 改变tokenId的拥有者
        _owners[tokenId] = to;

        // 将tokenId的授权取消，即授权映射的value改为address(0)
        _approve(to, address(0), tokenId);
    }

    // 安全转载的实际逻辑实现
    function _safeTransferFrom(address owner, address from, address to, uint tokenId, bytes memory _data) private {
        _transfer(owner, from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }

    // 进行安全转账
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public override {
        // 找出owner
        address owner = _owners[tokenId];
        require(_isApprovedOrOwner(owner, msg.sender, tokenId), "not owner or approved");

        _safeTransferFrom(owner, from, to, tokenId, data);
    }

    // 重载函数
    function safeTransferFrom(address from, address to, uint tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    // 铸币
    function _mint(address to, uint tokenId) internal virtual {
        // to不能是address(0)
        require(to != address(0), "mint to zero address");
        // tokenId不能是已经存在的
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁币
    function _burn(uint tokenId) internal virtual {
        address owner = _owners[tokenId];
        
        // 首先币必须存在，即有主人，同时，只有币的拥有者才能销毁币
        require(msg.sender == owner, "token don't be minted.");
        
        // 余额-1
        _balances[owner] -= 1;

        // tokenId的地址指向address(0)
        _owners[tokenId] = address(0);

        // tokenId授权的地址指向address(0)
        _approve(address(0), address(0), tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    // 进行安全检查，检查接收方是否实现了IERC721Receiver，并且重写了函数
    // 转账地址to可能是合约地址，也可能不是合约地址，如果是合约地址，就必须判断是否实现了IERC721Receiver接口，并重写了onERC721Received函数
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns(bytes4 retval) {
                // 判断选择器是否一致
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * 实现IERC721Metadata的tokenURI函数，查询metadata。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}