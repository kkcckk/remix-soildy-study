// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


contract OtherContract {
    uint256 private _x = 0;

    event Log(uint amount, uint gas);

    // 获取余额
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // 调整合约状态变量的值，同时还可以转账
    function setX(uint256 x) external payable {
        _x = x;

        // msg.value代表转账的金额
        if (msg.value > 0) {
            // 如果转账的金额大于0，触发转账事件
            emit Log(msg.value, gasleft());
        }
    }

    // 读取状态变量
    function getX() external view returns(uint256) {
        return _x;
    }
}

// 有四种方式调用其他合约的代码
contract CallContract {
    /** 
        第一种，传入合约地址，生成合约的引用，通过合约的引用调用其函数
        用法：合约名称(合约地址).合约函数(函数参数);
    */
    function callSetX(address _address, uint256 x) external {
        OtherContract(_address).setX(x);
    }

    /**
        第二种，传入合约变量，直接传入合约的引用，去调用相关函数的运行,即传入的参数的类型由adress变为合约的名称，如下，
        由于我们是在调用合约OtherContract里面的函数，所以直接传入 OtherContract _address，传入的_adress是一个地址值，
        但是类型由address->OtherContract，因为编译器会在编译的时候自动封装一个OtherContract(_address)的引用，会指向对应的合约
    */
    function callGetX(OtherContract _address) external view returns(uint256) {
        return _address.getX();
    }

    /**
        第三种，其实是第一种的变种，先创建一个合约，以便后面服用
    */
    function callGetX2(address _address) external view returns(uint256 x) {
        OtherContract oc = OtherContract(_address);

        // 调用对应的函数
        x = oc.getX();
    }

    /**
        第四种，和调用call的方式一样
        如果函数有payable修饰，表明是可以接收转账的，所以调用方式为
        合约名称(合约地址).函数名称{value: 转账金额}(函数参数);
        同意的，此合约的函数也得被payable修饰
    */
    function setTransferEth(address _address, uint256 x) external payable {
        OtherContract(_address).setX{value: msg.value}(x);
    }
}