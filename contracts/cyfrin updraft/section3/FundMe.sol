// 以美元为单位，设置最小的发送资金 Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    // 用户至少要发送5美元
    uint256 public minimumUsd = 5e18;

    function fund() public payable  {
        // 通过这个函数，可以进行转账，所有需要加上payable关键字
        // 从其他用户中获取资金 Get funds from users
        // 取钱 withdraw funds
        // 通过全局变量msg.value获取发送的金额,这个单位是wei
        // 但是对比的单位是美元，所以需要先把wei换算成美元，然后再和minimumUsd对比
        require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough eth");

        // 什么是revert？ What is a revert?
        // 回撤任何已经完成的行为，并且返回剩余的gas费用. Undo any action that have been done, and send the remaining gas back
    }

    function withdrawal() public {}

    // 获取以太坊的价格
    function getPrice() public view returns(uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    // 获取转化率
    function getConversionRate(uint256 ethAmount) public view returns(uint256) {
        //  获取以太的价格，用美元换算
        uint256 ethPrice = getPrice();
        // 计算转化率
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e10;
        return ethAmountInUsd;
    }
}