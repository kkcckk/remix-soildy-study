// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Event {
    // 地址映射余额
    mapping (address => uint256) public _balances;

    /** 
        定义一个事件,
        Transfer事件共记录了3个变量from，to和value，
        分别对应代币的转账地址，接收地址和转账数量，
        其中from和to前面带有indexed关键字，
        他们会保存在以太坊虚拟机日志的topics中，方便之后检索
    */    
    event Transfer(address indexed from, address indexed to, uint256 indexed a, uint256 value);

    // 定义一个转账函数，每次转账之后都会释放事件
    function _transfer(address from, address to, uint256 amount) external  {
        _balances[from] = 10000000; // 给转账地址一些初始代币

        _balances[from] -=  amount; // from地址减去转账数量
        _balances[to] += amount; // to地址加上转账数量

        // 释放事件
        emit Transfer(from, to, 1, amount);
    }
}