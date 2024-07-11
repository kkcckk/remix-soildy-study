// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC20.sol";


/**
    lp(liquidity provider tokens)流动性代币，用于去中心化交易所中的资金池，当用户质押相应的代币
    到交易所的资金池中，交易所会铸造相应的lp代币凭证，证明了质押的份额，供他们收取手续费

    质押之后，原先的代币会被锁定，在质押期到了之后，被质押的代币主人可以随时将代币提走，之所以要锁定
    lp代币，是为了防止用户撤出资金，导致资金池崩盘，其实可以理解为杀猪盘，每个人都把钱投入到一个资金池中，
    然后由这个资金池的主人去投资，投资人会得到一个对应自己投入金额的凭证。杀猪盘之所以叫杀猪盘是
    资金池主人把钱全部卷跑，带币圈中叫做rug pull

    一个简单的代币锁：
    事件：
        初始化，并锁定代币：event TokenLockStart(address indexed beneficary, address indexed token, uint256 startTimestamp, uint256 lockTimestamp);
        到期释放代币：event Release(address indexed beneficary, address indexed token, uint256 releasedTimestamp, uint256 releasedAmount);

    状态变量：
        受益人地址，在合约初始化的赋值，之后就不能再次被修改了：address public immutable beneficary;
        代币的地址，也就是受益人所持有的代币，也是只能在合约初始化的时候赋值，之后就不能再次修改了：address public immutable tokenAddress;
        锁定时间，代币锁定的时长，单位是秒：uint256 public immutable lockTimestamp;
        起始时间，代币锁定开始的时间，一般是使用区块的时间戳，也是在合约初始化的时候赋值，并且只能修改一次，后面就不能再次修改了：uint256 public immutable startTimestamp;

    函数：
        构造函数，用来初始化上述状态变量
        释放函数，受益人用来释放自己所持有的代币
*/


contract TokenLocker {
    event TokenLockStart(address indexed beneficary, address indexed tokenAddress, uint256 startTimestamp, uint256 lockTimestamp);
    event Released(address indexed beneficary, address indexed tokenAddress, uint256 releasedTimestamp, uint256 releasedAmount);

    // 受益人地址
    address public immutable beneficary;
    // 代币地址
    address public immutable tokenAddress;
    // 开始时间
    uint256 public immutable startTimestamp;
    // 锁定时间
    uint256 public immutable lockTimestamp;

    constructor(address beneficary_, address tokenAddress_, uint256 lockTimestamp_) {
        // 要求锁定时长必须大于0
        require(lockTimestamp_ > 0, "The time to lock the token must be greater than zero.");

        beneficary = beneficary_;
        tokenAddress = tokenAddress_;
        lockTimestamp = lockTimestamp_;
        startTimestamp = block.timestamp;

        // 释放事件
        emit TokenLockStart(beneficary, tokenAddress, startTimestamp, lockTimestamp);
    }

    // 释放
    function released() public {
        // 要求当前时间必须大于startTimestamp + lockTimestamp
        require(block.timestamp > startTimestamp + lockTimestamp);

        // 创建代币
        IERC20 lockTokenERC20 = IERC20(tokenAddress);

        // 获取余额
        uint256 releasedAmount = lockTokenERC20.balanceOf(address(this));
        // 余额必须大于0
        require(releasedAmount > 0, "insufficient balance");

        // 进行转账
        lockTokenERC20.transfer(beneficary, releasedAmount);

        emit Released(beneficary, tokenAddress, block.timestamp, releasedAmount);
    }
}