// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract Fallback {
    /**
        receive()和fallback(),主要在以下两种情况下使用：
        1. 接收ETH
        2. 处理合约中不存在的函数调用（代理合约proxy contact）
        在0.6.x版本之前只有fallback()，之后才拆分成receive()和fallback()

        注意：其实只要函数有payable修饰，就可以用作接收eth
    */

    /**
        receive()函数，收到ETH转账时调用，并且一个合约中最多只能存在一个receive()
        声明方式，不需要加function关键字:
            receive() external payable {...}
        receive()函数没有参数，没有返回值，并且只能被external和payable修饰
        触发：在接收到ETH时触发，也就是对方调用send() transfer() call()
    */

    event Received(address sender, uint value);

    receive() external payable { 
        // 当转账的时候，会触发这个函数，并且会触发接收事件，把函数调用者地址和金额打印出来
        emit Received(msg.sender, msg.value);
    }


    /**
        fallback()函数，会在调用不存的函数（代理合约）或者转账时触发。可用于转账或者代理合约
        声明方式，不需要加function关键是：
            fallback() external payable {....}
        只能被external修饰,如果是转账的话，还得加上payable
    */

    event Fallbacked(address sender, uint value, bytes data);

    fallback() external payable {
        emit Fallbacked(msg.sender, msg.value, msg.data);
    }

    /**
        receive()和fallback()的区别:
            1. 触发方式不一样：都能用于接收转账，但是msg.data为空且receive()存在时，会触发receive()；
            如果msg.data不为空或者receive()不存在时，会触发fallback()，此时的fallback()一定要加上payable

        如果receive()和fallback()都不存在时，转账会报错
    */
}