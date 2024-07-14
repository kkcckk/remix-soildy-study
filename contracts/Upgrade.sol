// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


/**
    逻辑和代理合约一样，改变逻辑合约地址的指向，从而达到升级合约的目的
*/

// 升级合约
contract SimpleUpgrade {
    address public implementation;
    address public admin;
    
    string public words;

    constructor(address implementation_){
        admin = msg.sender;
        implementation = implementation_;
    }

    // fallback函数，调用逻辑合约
    fallback() external payable {
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // 升级合约，改变逻辑合约地址
    function upgrade(address newImplementation) external {
        require(admin == msg.sender, "SimpleUpgrade:: Only admin can upgrade contract.");
        implementation = newImplementation;
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