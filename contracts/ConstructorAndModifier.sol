// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ConstructorAndModifier {
    address public owner;

    // 构造器是部署合约的时候会运行一次，用来初始化合约的参数
    constructor(){
        owner = msg.sender;
    }

    // 修饰器，运用场景：函数运行前的检查
    modifier onlyOwner {
        require(owner == msg.sender); // 进行权限检查
        _; // 这代表运行函数代码块的地方
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    } 
}