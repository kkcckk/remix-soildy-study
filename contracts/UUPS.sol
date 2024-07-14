// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
    和透明代理一样，都是为了解决函数选择器冲突问题，
    但是通用可升级代理标准(UUPS),是把升级功能放在逻辑合约中，
    这样就避免函数选择器冲突问题
*/
contract UUPSProxy {
    address public implementation;
    address public admin;
    string public words;

    constructor(address implementation_) {
        implementation = implementation_;
        admin = msg.sender;
    }

    // 回调函数
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }
}


// 逻辑1
contract UUPS1 {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "UUPS1";
    }

    function upgrade(address implementation_) external {
        require(msg.sender == admin, "Must be admin");
        implementation = implementation_;
    }
}

// 逻辑2
contract UUPS2 {
    address public implementation;
    address public admin;
    string public words;

    function foo() public {
        words = "UUPS2";
    }

    function upgrade(address implementation_) external {
        require(msg.sender == admin, "Must be admin");
        implementation = implementation_;
    }
}