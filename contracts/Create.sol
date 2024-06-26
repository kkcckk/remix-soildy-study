// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
    有两种方式可以在合约中创建合约
        1. 使用CREATE（和java创建类一样的方式）
            Contract x = new Contract{value : _value}(param);
            其中Contract是创建的合约名称
            {value: _value}是创建合约时初始化的以太币的个数，前提是构造器是payable的
            param是构造器的参数，如果有的话

            使用CREATE创建的新合约的地址的计算方式是 新地址=hash(创建者地址, nonce)，因为nonce是变化的，
            所以使用CREATE创建的新合约地址也是变化的，不可预测

        2. 使用CREATE2（和java创建类一样的方式）
            和CREATE的创建方式大致相同，唯一的区别就是计算合约的方式不一样，CREATE2需要再多传一个参数salt，
            Contract x = new Contract{salt: _salt, value: _value}(param);
            其中Contract是创建的合约名称
            {salt: _salt, value: _value}是创建合约时初始化的以太币的个数，前提是构造器是payable的;salt是计算新合约地址时使用，加盐是为了哈希值更分散
            param是构造器的参数，如果有的话

            使用CREATE2的方式创建的新合约的地址计算方式和四个值有关：
                0xff，一个常数，避免和CREATE冲突
                CreateAddress，调用CREATE2的当前合约（创建合约）地址
                salt，创建者指定的bytes32类型的值，主要目的是来影响新合约地址的生成
                initcode，新合约的初始字节码（合约的Creation Code和构造函数的参数）

                新地址计算公式：新地址 = hash("0xFF", 创建者地址, salt, initcode);

            具体使用方式，请看Create2.sol文件

*/

// 使用CREATE方式创建合约
// 模仿uniswap
contract Pair {
    address public factory;
    address public token01;
    address public token02;

    constructor() payable {
        factory = msg.sender;
    }

    function initialize(address _token01, address _token02) external {
        require(msg.sender == factory, "forbidden");
        token01 = _token01;
        token02 = _token02;
    }
}


// 创建代币的工厂类
contract PairFactory {
    mapping(address => mapping(address => address)) public getPair;
    // 保存所有代币地址
    address[] public allPair;

    function createPair(address tokenA, address tokenB) external returns(address pairAddr) {
        // 创建代币对
        Pair pair = new Pair();

        // 初始化
        pair.initialize(tokenA, tokenB);

        pairAddr = address(pair);
        
        allPair.push(pairAddr);
        getPair[tokenA][tokenB] = pairAddr;
        getPair[tokenB][tokenA] = pairAddr;
    }
}