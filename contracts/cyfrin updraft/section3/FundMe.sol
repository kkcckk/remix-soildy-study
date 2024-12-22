// 以美元为单位，设置最小的发送资金 Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./librarys/PriceConverter.sol";


/**
    在remix中，部署好的合约在左侧，如果是红色的话闲显示转账功能，如果是橙色
**/

// 降低的技巧gas constant immutable
// 创建自定义错误，用来代替在require中的字符串，这样可以节省不少gas


// 自定义错误
error NotOwner();

contract FundMe {
    // 使用library
    using PriceConverter for uint256;

    // 用户至少要发送5美元
    // 如果变量创建之后，只会在创建的时候赋值一次，可以使用constant进行修饰，可以节省不少gas，同时变量名全部大写，用下划线分隔
    uint256 public constant MINIMUM_USD = 5e18; // 1 * 10 ** 18=1额8

    // 查看eth当前的美元价格
    uint256 public pr = 0;

    // 保存交易地址
    address[] public funders;

    // 保存每个交易地址发送了多少金额
    // 以下写法是一种语法糖，为了更易阅读这个mapping是什么作用
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    // 合约的拥有者，并通过构造器去初始化
    // 在定义变量之后，只需要修改一次，可以使用immutable，同时在前缀加入i_
    // 使用immutable修饰的变量可以在运行期修改一次，而constant修饰的变量的值会在编译器进行赋值
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        pr = msg.value.getConversionRate();
        // 通过这个函数，可以进行转账，所有需要加上payable关键字
        // 从其他用户中获取资金 Get funds from users
        // 取钱 withdraw funds
        // 通过全局变量msg.value获取发送的金额,这个单位是wei
        // 但是对比的单位是美元，所以需要先把wei换算成美元，然后再和MINIMUM_USD对比
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough eth");

        // 保存发送金额的地址
        // msg.sender 是调用fund()函数，并且发送代币到本合约的交易者
        funders.push(msg.sender);

        // 保存每个地址的交易金额
        addressToAmountFunded[msg.sender] += msg.value;

        // 什么是revert？ What is a revert?
        // 回撤任何已经完成的行为，并且返回剩余的gas费用. Undo any action that have been done, and send the remaining gas back
    }

    function withdrawal() public onlyOwner {
        //  for循环
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // 重置数组中的地址
        // 使用new关键字创建
        funders = new address[](0);

        // 实际取钱的方法
        // 有三种方法

        // transfer gas上限是2300，如果超过2300会报错
        // msg.sender 是一个地址类型
        // 而payable(msg.sender)是一个付款地址
        // payable(msg.sender).transfer(address(this).balance);

        // send gas上限是2300，会返回是否成功的布尔值
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // 使用require进行判断， 失败了进行revert
        // require(sendSuccess, "Send failed");

        // call 可以自定义gas，同时可以调用任意函数通过函数签名
        // 是一个低级命令（底层命令）
        // 会返回两个变量，一个调用是否成功，一个是bytes类型的数据，这个变量保存了通过call调用的任意函数的结果或者返回值
        // bytes memory dataReturned 返回的bytes类型的值如果不用可以不写
        // 建议使用call函数进行转账

        // 取钱之前先判度权限
        // require(i_owner == msg.sender, "Must be i_owner!"); // 这一行用权限修饰符替代了

        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    // 修饰器
    modifier onlyOwner() {
        // 使用自定义错误，而不是使用require，可以更加节省gas
        // require(msg.sender == i_owner, "Sender is not i_owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }

        _; // 占位符，用来占位代码执行的顺序，在require上方，先执行代码；反之后执行代码
    }

    // 主动向合约进行转账而不是通过调用函数进行转账
    // receive()和fallback()
    //  如果转账的同时，还发送了一些消息的话，会发送到fallback()函数上，反之，发送到receive()函数上
    receive() external payable {
        // 在这个里面调用fund函数，只是在别人主动进行转账时，会有一个通知
        fund();
    }
    fallback() external payable {
        // 在这个里面调用fund函数，只是在别人主动进行转账时，会有一个通知
        fund();
    }
}
