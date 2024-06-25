// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


/**
    功能和call是一样的，
    只不过delegatecall是改变自身合约的状态变量
    而call改变的是被调用合约的状态变量
*/
contract Delegatecall {
    /** 
        调用方式:目标合约地址.delegatecall(二进制编码);
        其中,二进制编码是使用abi去调用:abi.encodeWithSignature(signatureString, arg);
        函数签名又是函数名称(参数类型,...);
        arg使用逗号去分割具体的参数
        e.g abi.encodeWithSignature("f(uint, address)", _x, _address);

        和call不一样的是,delegatecall调用合约的时候可以指定gas,但是不能指定eth的数量

        注意:
        1. 发起调用的合约必须要和被调用合约有着相同结构的变量存储布局
            比如发起调用合约B中有变量
                uint public num;
                address public sender;
            那么被调用合约C中也应该有如下变量
                uint public _num;
                address public _sender;
            
            我理解是修饰字段 类型 顺序都应该是一模一样,名称也最好保持一致,但是不一样也是可以的
        
        2. 和call一样,也是不安全的,不知道被调用合约的源码,不能保证对方的源码是安全的,不建议使用delegatecall
        去调用合约

        使用场景
        1. 代理合约(proxy contract)
        2. EIP-2535 Diamonds(钻石)
    */ 
}


contract C {
    uint8 public _num;
    address public _sender;

    function setVars(uint8 num) public payable {
        _num = num;
        _sender = msg.sender;
    }
}


contract B {

    event CallRecord(string msg, bool success, bytes data, address addr);
    event DelegateCallRecord(string msg, bool success, bytes data, address addr);

    uint8 public _num;
    address public _sender;

    // 下面会分别使用call调用和delegatecall调用
    function callSetVars(uint8 num, address _addr) external payable {
        (bool success, bytes memory data) = _addr.call(
            // 注意,如果被调用合约的函数的参数类型是uint,那么在通过abi调用的时候
            // 传入函数的签名得使用uint256,因为编译器会把uint自动解析为uint256
            abi.encodeWithSignature("setVars(uint8)", num)
        );

        emit CallRecord("callSetVars", success, data, _addr);
    }

    function delegateSetVars(uint8 num, address _addr) external payable {
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint8)", num)
        );

        emit DelegateCallRecord("DelegateSetVars", success, data, _addr);
    }


    /**
        结果分析
        调用callSetVars(10, 0x1d142a62E2e98474093545D4A3A0f7DB9503B8BD):
            账户通过调用合约B的callSetVars函数,去调用合约C中的setVars函数,
            改变了合约C中的两个状态变量,
            所以合约C中_num=10,而_sender=msg.sender=B的合约的地址=0x86cA07C6D491Ad7A535c26c5e35442f3e26e8497
        所以符合call的特性,调用合约代码改变的是被调用合约中的状态变量

        调用delegateSetVars(100, 0x1d142a62E2e98474093545D4A3A0f7DB9503B8BD):
            账户通过调用合约B的delegateSetVars函数,去调用合约C中的setVars函数,
            改变了合约B中的两个状态变量,
            所以合约B中_num=100,而_sender=msg.sender=账户地址=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        所以符合call的特性,调用合约代码改变的是被调用合约中的状态变量
    */
}