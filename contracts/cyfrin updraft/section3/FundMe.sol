// 以美元为单位，设置最小的发送资金 Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./librarys/PriceConverter.sol";


contract FundMe {

    // 使用library
    using PriceConverter for uint256;

    // 用户至少要发送5美元
    uint256 public minimumUsd = 5e18;

    // 查看eth当前的美元价格
    uint256 public pr = 0;

    // 保存交易地址
    address[] public funders;

    // 保存每个交易地址发送了多少金额
    // 以下写法是一种语法糖，为了更易阅读这个mapping是什么作用
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        pr = msg.value.getConversionRate();
        // 通过这个函数，可以进行转账，所有需要加上payable关键字
        // 从其他用户中获取资金 Get funds from users
        // 取钱 withdraw funds
        // 通过全局变量msg.value获取发送的金额,这个单位是wei
        // 但是对比的单位是美元，所以需要先把wei换算成美元，然后再和minimumUsd对比
        require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough eth");

        // 保存发送金额的地址
        // msg.sender 是调用fund()函数，并且发送代币到本合约的交易者
        funders.push(msg.sender);

        // 保存每个地址的交易金额
        addressToAmountFunded[msg.sender] += msg.value;

        // 什么是revert？ What is a revert?
        // 回撤任何已经完成的行为，并且返回剩余的gas费用. Undo any action that have been done, and send the remaining gas back
    }

    function withdrawal() public {}
}