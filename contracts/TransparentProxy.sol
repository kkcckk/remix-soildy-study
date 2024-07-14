// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
    透明代理，和可升级代理不同的是，会进行权限判断，只有管理员才能调用升级合约，
    只有逻辑合约才能调用逻辑合约里面的函数
*/

contract TransparentProxy {
    // 逻辑合约地址
    address public implementation;

    // 管理员地址
    address public admin;

    // 字符串，通过代理合约改变
    string public words;

    // 构造函数
    constructor(address implementation_) {
        implementation = implementation_;
        admin = msg.sender;
    }

    // 回调函数
    fallback() external payable {
        // 只允许管理员调用
        require(msg.sender != admin, "Don't be admin.");
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    function upgrade(address implementation_) external {
        require(msg.sender == admin, "Must be admin.");
        implementation = implementation_;
    }
}


// 旧逻辑合约
contract OldLogic {
    address public implementation;
    address public admin;
    
    string public words;

    function foo() public {
        words = "old";
    }
}

// 新逻辑合约
contract NewLogic {
    address public implementation;
    address public admin;
    
    string public words;

    function foo() public {
        words = "new";
    }
}