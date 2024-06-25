// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error SendFailed(); // send失败时候调用
error CallFailed(); // call失败的时候调用

contract SendEth {
    /**
        有四种转账的方式
        1. transfer:gas 2300
        2. send:gas 2300
        以上两个存在风险，如果gas 超过2300，则以上调用会失败，所以对方合约的fallback()或者receive()里面的逻辑不能很复杂

        send:
            用法：接收地址.send(金额)
            如果转账失败，不会revert
            有返回值，是一个bool类型的值，代表转账成功或者失败

        transfer:
            用法：接收地址.transfer(金额)
            如果转账失败，会自动revert
            没有返回值
        =================
        3. call:gas 自定义
        4. delegatecall:gas 自定义
        以上两个调用的时候可以自定义gas，所以对方fallback()或者receive()的逻辑可以非常复杂
        同时还可以调用目标地址合约的代码，不同的是前者使用的是目标地址的资源（余额、存储等），
        后者使用的是自身地址的资源（余额、存储）

        call:
            用法：接收地址.call{value: 金额}("")
            如果转账失败，不会revert
            有返回值，是一对二元组，可以用两个参数来接收，一个是bool类型的值，表示是否成功转账，一个是bytes类型的值，代表被调用函数返回的值，如果没有返回值，则位空
            
    */
    
    // 初始化合约的时候,如果想让合约具备初始金额，可以使用构造器+payable的方式，在合约部署的时候，可以传入一定金额作为初始金额
    // 这个时候不会调用合约的receive()或者fallback()，这两个只有合约部署成功之后，发送了转账才会被调用
    constructor() payable {}

    // 接收
    receive() external payable { }

    // 使用send的方式发送
    function sendEth(address payable _to, uint256 amount) external payable {
        bool success = _to.send(amount);

        if (!success) {
            revert SendFailed();
        }
    }

    // 使用transfer的方式发送
    function transferEth(address payable _to, uint256 amount) external payable {
        _to.transfer(amount);
    }

    // 使用call的方式发送
    function callEth(address payable _to, uint256 amount) external payable {
        (bool success, ) = _to.call{value: amount}("");

        if (!success) {
            revert CallFailed();
        }
    }

}


contract ReceiveEth {
    // 接收到转账后触发日志
    event Log(uint amount, uint gas);

    // 接收转账
    receive() external payable { 
        emit Log(msg.value, gasleft());
    }

    // 获取余额
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}