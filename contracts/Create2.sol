// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract Pair {
    address public factory;
    address public token01;
    address public token02;

    constructor() payable {
        factory = msg.sender;
    }

    function initialize(address _token01, address _token02) external {
        require(factory == msg.sender, "forbidden");
        token01 = _token01;
        token02 = _token02;
    }
}


contract PairFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairAddrs;

    function create2Pair(address tokenA, address tokenB) external returns(address pairAddr) {
        // 避免A和B地址一样
        require(tokenA != tokenB, "tokenA is not similar to tokenB");
        
        // tokenA和tokenB，按照地址大小进行排序
        (address token01, address token02) = tokenA > tokenB ? (tokenB, tokenA) : (tokenA, tokenB);

        // 计算salt
        bytes32 salt = keccak256(abi.encodePacked(token01, token02));

        // 使用create2部署
        Pair pair = new Pair{salt: salt}();

        pair.initialize(tokenA, tokenB);

        pairAddr = address(pair);

        allPairAddrs.push(pairAddr);

        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;

    }

    // 计算Pair地址
    function calculatePairAddress(address tokenA, address tokenB) public view returns(address predictedAddress) {
        // 避免A和B地址一样
        require(tokenA != tokenB, "tokenA is not similar to tokenB");
        
        // tokenA和tokenB，按照地址大小进行排序
        (address token01, address token02) = tokenA > tokenB ? (tokenB, tokenA) : (tokenA, tokenB);

        // 计算salt
        bytes32 salt = keccak256(abi.encodePacked(token01, token02));

        // 计算pair地址
        // 在solidity中，可以将类型uint160转换为address，因为address类型本质上是一个160位的值
        predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(type(Pair).creationCode))))));
    }
}