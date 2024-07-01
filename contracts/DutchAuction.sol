// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC721.sol";
import "./abstractContract/Ownable.sol";


/**
    荷兰拍卖，竞拍开始的价格是最高的，后面每隔一段时间，价格会降低，
    其实这个拍卖内容不是拍卖NFT，而是拍卖制作NFT的价格，时间越后，制作的价格越低
*/
contract DutchAuction is Ownable, ERC721 {
    // NFT 总数
    uint256 public constant COLLECTION_SIZE = 10000;

    // 起拍价
    uint256 public constant AUCTION_START_PRICE = 1 ether;

    // 最终价
    uint256 public constant AUCTION_END_PRICE = 0.1 ether;

    // 拍卖时长
    uint256 public constant AUCTION_TIME = 10 minutes;

    // 每过间隔时间，就会调整一次价格
    uint256 public constant AUCTION_DROP_TIME_INTERVAL = 1 minutes;

    // 间隔时间衰减的价格，等于(最终价格 - 起拍价) / (拍卖时长 / 间隔时间)
    uint256 public constant AUCTION_DROP_PER_STEP = (AUCTION_START_PRICE - AUCTION_END_PRICE) / (AUCTION_TIME / AUCTION_DROP_TIME_INTERVAL);

    // 拍卖开始时间戳
    uint256 public auctionStartTime;

    // token metadata URI
    string private _baseTokenURI;

    // 所有拍卖的tokenId
    uint256[] private _allTokens;

    constructor() Ownable(msg.sender) ERC721("KX Dutch Auction", "KX Dutch Auction") {
        // 创建拍卖时，拍卖开始时间戳就是区块时间戳
        auctionStartTime = block.timestamp;
    }

    // 总共的tokenId数量
    function totalSupply() public view virtual returns(uint256) {
        return _allTokens.length;
    }

    // 新增加一个tokenId，私有函数
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }

    // 开始拍卖
    function auctionMint(uint256 quantity) external payable {
        // 因为要多次使用auctionStartTime，所以保存在本地，减少多次去evm中读取状态数据
        uint256 _auctionStartTime = uint256(auctionStartTime);

        // 要求设置的开始时间戳不为0，即_auctionStartTime = auctionStartTime != 0，并且当前的块时间戳block.timestamp > _auctionStartTime = auctionStartTime
        require(_auctionStartTime != 0 && _auctionStartTime < block.timestamp, "auction is not started yet.");

        // 总数要大于拍卖的数量，即totalSupply() > quantity
        require(totalSupply() + quantity <= COLLECTION_SIZE, "not enough remaining reserved for auction to suppot desired mint amount.");

        // 获取当前价格
        uint256 price = getAuctionPrice();

        // 计算当前所需要花费的价格
        uint256 totalCost = price * quantity;

        // 判断拍卖者的拍卖价格和当前的价格的大小，多退少回退交易
        require(msg.value >= totalCost, "Need to send more ETH");

        // 铸币
        for(uint256 i = 0; i < quantity; i++) {
            uint256 mintIndex = totalSupply();
            _mint(msg.sender, mintIndex);
            _addTokenToAllTokensEnumeration(mintIndex);
        }

        if (msg.value - totalCost > 0) {
            (bool success, ) = payable(msg.sender).call{value: msg.value - totalCost}("");
        }

    }

    // 获取实时价格
    function getAuctionPrice() public view returns(uint256) {
        // 如果当前区块时间小于开始时间，说明还没开始，返回最大值
        if (block.timestamp < auctionStartTime) {
            return AUCTION_START_PRICE;
        } else if (block.timestamp - auctionStartTime >= AUCTION_TIME) {
            // 如果当前区块时间-开始时间>=拍卖时间，说明拍卖结束了，返回最小值
            return AUCTION_END_PRICE;
        } else {
            // 如果在拍卖开始时间和结束时间中间，则根据时间间隔，然后除以时间衰减步长，算出价格递减了多次，用初始价格-一共递减得价格，得出当前得价格 
            return AUCTION_START_PRICE - (AUCTION_DROP_PER_STEP * ((block.timestamp - auctionStartTime) / AUCTION_DROP_TIME_INTERVAL));
        }
    }

    // 设置开始时间，只有拍卖合约创建者才能设置
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    // 返回元数据URI
    function _baseURI() internal view virtual override returns(string memory) {
        return _baseTokenURI;
    }

    // 拥有者设置 Base URI
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    // 提款函数
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");

        require(success, "Transfer failed.");
    }
}