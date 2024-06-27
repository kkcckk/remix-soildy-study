// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


/**
    try-catch可以捕获异常，和java中的一样
    只能用于external函数，或者创建合约时constructor的调用
    用法：
        try externalContract.函数(函数参数...) [returns(类型 参数名称)] {
            正常代码运行
        } catch Error() {
            运行失败运行
        }
    
    可以用于assert() require() revert()的异常捕获
*/

contract EXContract {
    constructor(uint a) {
        require(a != 0, "invalid number");
        // 返回的bytes类型
        assert(a != 1);
    }

    function onlyEven(uint256 b) external pure returns(bool success) {
        require(b % 2 == 0, "Ups! Reverting");
        success = true;
    }
}


contract TryCatchContract {
    event SuccessEvent(string s);
    event CatchEvent(string message);
    event CatchByte(bytes data);

    EXContract exContract;

    constructor() {
        exContract = new EXContract(2);
    }

    // 已创建的合约进行函数调用
    function execute(uint amount) external returns(bool success) {
        try exContract.onlyEven(amount) returns(bool _success) {
            emit SuccessEvent("function is called success");
            success = _success;
        } catch Error(string memory reason) {
            emit CatchEvent(reason);
        }
    }

    // 新创建合约
    function executeCreateContract(uint a) external returns(bool success) {
        try new EXContract(a) returns(EXContract _exc) {
            emit SuccessEvent("EXContract is created success");
            exContract = _exc;
            success = exContract.onlyEven(a);
        } catch Error(string memory reason) {
            emit CatchEvent(reason);
        } catch (bytes memory reason) {
            emit CatchByte(reason);
        }
    }
}