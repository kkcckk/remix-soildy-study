// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC20.sol";

/**
    代币锁：TokenLocker
    定义：用户将一定量的代币转入合约中，换取等价值的lp代币，到一定时间后，可以通过lp代币换回之前代币
    lp（liquid provider token）：是dex去中心化交易所或流动性池中表示流动性提供者的一种代币。
    可以理解为一个集资，有很多钱，然后每个人付了钱的人都会有一个表示相应金额的证明牌子。

    一个简单的代币锁合约结构：
        事件：
            锁仓开始事件：记录了代币受益人地址、代币地址、开始时间、结束时间
            释放代币事件：记录了代币受益人地址、代币地址、释放时间、释放数量

            event TokenLockStart(address indexed beneficary, address indexed token, uint256 startTimestamp, uint256 endtTimestamp);
            event Release(address indexed beneficary, address indexed token, uint256 releasedTimestamp, uint256 releasedAmount);

        状态变量：
            受益人地址：address public immutable beneficary;
            代币地址：address public immutable token;
            开始时间：uint256 public immutable startTimestamp;，一般设置为区块时间戳
            锁仓时间：uint256 public immutable lockTimestamp;

        函数：
            构造函数，初始化状态变量
            释放代币
*/


contract TokenLock {
    address public immutable beneficary;
    address public immutable token;
    uint256 public immutable startTimestamp;
    uint256 public immutable lockTimestamp;

    event TokenLockStart(address indexed beneficary, address indexed token, uint256 startTimestamp, uint256 lockTimestamp);
    event Release(address indexed beneficary, address indexed token, uint256 releasedTimestamp, uint256 releasedAmount);


    constructor(address beneficary_, address token_, uint256 lockTimestamp_) {
        require(beneficary_ != address(0), "beneficary can't be zero address.");
        require(lockTimestamp_ > 0, "lock timestamp must be greater then zero.");

        beneficary = beneficary_;
        token = token_;
        startTimestamp =  block.timestamp;
        lockTimestamp = lockTimestamp_;

        emit TokenLockStart(beneficary, token, startTimestamp, lockTimestamp);
    }

    // 释放函数
    function release() public {
        require(block.timestamp > startTimestamp + lockTimestamp, "The time to unlock the token has not yet arrived.");

        // 使用erc代币进行转账
        // 代币的余额必须大于0
        IERC20 e20 = IERC20(token);
        uint256 balance = e20.balanceOf(address(this));
        require(balance > 0, "insufficient balance");

        e20.transfer(beneficary, balance);

        emit Release(beneficary, token, block.timestamp, balance);
    }
}