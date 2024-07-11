// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./ERC20.sol";


/**
    使用线性的方式，每过一定时间，在归属期范围内，释放一定数量的代币
    
    使用该合约有个前提是，已知是代币的地址，同时该合约是保存了一定数据量的代币的，入erc20，是可以通过erc.balanceOf(线性合约地址)去查询的

    一共有四个属性，在合约的构造函数中，会对数据进行初始化，初始化之后，数据不能再被修改：
        收益地址：beneficiary
        起始时间：startTime，一般使用block.timstamp
        时间间隔：duration
        上面三个参数使用immutable修饰，只允许修改一次
        ===================
        代币地址与代币已释放数量映射：tokenReleased

    三个函数：
        构造函数：初始化三个参数
        释放代币：受益人可以主动调用这个函数，并将一定数据量的代币转入受益人地址
        计算可释放地址：通过计算公式计算出可以释放的代币的数量

    简化版的线性释放代码逻辑，详细内容请见：
    https://github.com/OpenZeppelin/openzeppelin-contracts/blob/4a9cc8b4918ef3736229a5cc5a310bdc17bf759f/contracts/finance/VestingWallet.sol
*/

contract TokenVesting {
    // 释放代币的事件
    event TokenReleased(address indexed token, uint256 amount);

    // 受益人地址
    address public immutable beneficary;
    // 开始时间
    uint256 public immutable startTime;
    // 时间间隔
    uint256 public immutable duration;

    // 已释放代币与受益人映射
    mapping (address => uint256) public tokenReleased;

    // 构造器
    constructor(address beneficary_, uint256 duration_) {
        beneficary = beneficary_;
        startTime = block.timestamp;
        duration = duration_;
    }

    // 释放代币,参数token为代币的地址
    function release(address token) public {
        // 计算可以释放的代币
        uint256 releasedAmount = vestedAmount(token, uint256(block.timestamp));

        // 计算用户可获取的代币
        uint256 beneficaryAmount = releasedAmount - tokenReleased[token];

        // 更新token代币已经释放的代币数量
        tokenReleased[token] += beneficaryAmount;

        // 转给用户
        IERC20(token).transfer(beneficary, beneficaryAmount);

        //触发事件
        emit TokenReleased(token, beneficaryAmount);
    }

    // 计算可释放代币数量
    function vestedAmount(address token, uint256 time) public view virtual returns(uint256) {
        // 查询该合约一共能释放的代币数量
        uint256 totalAmount = IERC20(token).balanceOf(address(this)) + tokenReleased[token];

        // 通过时间进行判断是否释放代币，释放多少代币
        if (time < startTime) {
            // 如果还没到时间，释放0个代币
            return 0;
        } else if (time > startTime + duration) {
            // 如果超过了起始时间+时间间隔，说明可以全部释放代币
            return totalAmount;
        } else {
            // 否则按照时间比例去释放
            return (totalAmount * (time - startTime)) / duration;
        }
    }
}