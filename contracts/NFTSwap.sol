// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IERC721Receiver.sol";
import "./interface/IERC721.sol";
import "./KXERC721.sol";

/**
    NFT交易所，因为要接收NFT，所以必须实现IERC721Receiver接口，流程：
    卖家先在交易所上架NFT，
    上架成功之后，卖家可以更改NFT的价格，也可以下架NFT
    买家在卖家上架NFT之后，可以使用eth购买NFT
    ==============
    1. 卖家在交易所上架NFT
        需要提供NFT的地址，tokenId，上架的价格，价格必须上架为大于0才合理
        但是有个前提，对应的tokenId应该授权给NFT交易所处理了，
        之后卖家将NFT转移给NFT交易所，也就是进行transfer

    2. 卖家在交易所下架NFT
        需要提供NFT的地址，tokenId，通过这两个键获取Order结构体，同时获取tokenId的卖家地址，
        之后通过NFT交易所将NFT交易回去卖家，并删除对应映射中的订单

    3. 更新NFT的价格
        根据提供的NFT地址以及tokenId，找到对应的Order结构体，然后更新一下对应price字段的值

    4. 交易
        传入NFT地址，以及tokenId，
        然后比较买家(msg.sender)价格(msg.value)和NFT的价格，如果大于等于NFT的价格，交易成交，
        通过safeTransferFrom函数将NFT转入买家地址，
        通过NFT地址以及tokenId找出Order结构体，获取price，转入price给卖家，
        同时，如果有多余的钱，那么会将多余的钱转会买家    
*/
contract NFTSwap is IERC721Receiver {
    // 上架、下架、更新价格、交易事件
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPric);

    event Log(string indexed content, address to);

    // tokenId订单结构体
    struct Order {
        // tokenId
        address owner;

        // 价格
        uint price;
    }

    // 记录NFT地址，tokenId对应的订单
    mapping (address => mapping (uint256 => Order)) public nftList;

    // 上架
    function list(address _nft, uint256 tokenId, uint price) public {
        IERC721 nft = IERC721(_nft);

        // 检查tokenId的拥有者是否授权NFTSwap处理nft
        require(nft.getApproved(tokenId) == address(this), "Need approved");

        // 价格设置必须大于0
        require(price > 0, "The price of tokenId must be set to non zero");

        // 前面检查都没问题了，需要开始转账了
        // 先获取Order
        Order storage order = nftList[_nft][tokenId];
        
        // 给order赋值
        order.owner = msg.sender;
        order.price = price;

        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        emit List(msg.sender, address(this), tokenId, price);
    }

    // 下架
    function revoke(address _nft, uint256 tokenId) public {
        Order storage order = nftList[_nft][tokenId];

        // 判断是否是卖家自己调用的
        require(order.owner == msg.sender, "Not owner");

        IERC721 nft = IERC721(_nft);

        // 只有NFTSwap才能进行转账，所有tokenId的owner的地址和address(this)一致
        require(nft.ownerOf(tokenId) == address(this), "Invalid order");

        // 前面判断都没有问题，开始转账
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        // 删除映射中的订单
        delete nftList[_nft][tokenId];

        emit Revoke(msg.sender, _nft, tokenId);
    }

    // 更新价格
    function update(address _nft, uint256 tokenId, uint price) public {
        Order storage order = nftList[_nft][tokenId];
        
        // 判断是否是卖家操作
        require(msg.sender == order.owner, "Invalid owner");

        // nft必须是已经上架了的
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(tokenId) == address(this), "The tokeId is not listed");

        // price的价格必须大于0
        require(price > 0, "The price of tokenId is must be set to non zero");

        order.price = price;
    }

    // 买NFT
    function purchase(address _nft, uint256 tokenId) public payable {
        // 判断购买的tokenId是否上架了
        IERC721 nft = IERC721(_nft);
        require(nft.ownerOf(tokenId) == address(this), "The tokenId is not listed");

        // 获取订单,比较价格
        Order storage order = nftList[_nft][tokenId];
        require(order.price <= msg.value, "Your price is less than the price of tokenId");

        // 进行nft转账
        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        // 进行以太币的转账
        // (bool success_owner, ) = payable(order.owner).call{value: order.price}("");
        
        // // 如果有多余，转回给买家
        // if (success_owner && msg.value - order.price > 0) {
        //     (bool success_purchase, ) = payable(msg.sender).call{value: msg.value - order.price}("");
        //     if(success_purchase) {
        //         delete success_purchase;
        //     }
        // }

        payable(order.owner).transfer(order.price);
        payable(msg.sender).transfer(msg.value - order.price);

        // 销毁对应的订单
        delete nftList[_nft][tokenId];

        emit Purchase(msg.sender, _nft, tokenId, order.price);
    }

    fallback() external payable { }
    receive() external payable { }

    // 作为接收NFT的一方，必须重写这个方法
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}