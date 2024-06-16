// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract FunctionType{
    uint256 public _num = 5;

    function add() external{
        _num = _num + 1;
    }

    // pure既不能读取状态，也不能修改状态
    function addPure(uint number) external pure returns(uint256 newNumber) {
        newNumber = number + 1;
    }

    // view只能读取状态，不能修改状态
    function addView() external view returns(uint256 newNumber){
        newNumber = _num + 1;
    }

    // internal 只能内部被调用的函数
    function minus() internal {
        _num = _num - 1;
    }

    // external 合约的函数可以被外部合约调用，同时也可以调用合约内部的函数
    function minusCall() external {
        minus();
    }

    // 可以付钱的函数
    function minusPayable() external payable returns(uint256 balance) {
        minus();
        balance = address(this).balance;
    }
}