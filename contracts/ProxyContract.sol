// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
    代理合约，可以用于合约升级，同时可以起到合约逻辑的复用功能，节省gas
    代理合约会将数据存储和逻辑分开在不同的两个合约中，代理合约只保存逻辑合约的地址和状态变量，
    如果逻辑出现问题了，修改后重新部署之后，只需要把代理合约中保存的逻辑合约的地址指向
    新逻辑合约的地址就行了

    使用合约的fallback函数进行delegatecall调用

    使用代理合约和实现合约（逻辑合约）的注意事项
    1. 状态变量声明顺序：代理合约和实现合约中的状态变量必须以相同的顺序声明。即使类型相同，但顺序不同也会导致错误
    2. 代理合约和实现合约中相同位置的变量必须具有相同的类型。否则，变量的读取和写入操作会不一致。
    3. 在使用可升级代理合约模式时，确保新版本的实现合约保持与旧版本相同的状态变量布局，或者进行适当的存储迁移。
*/

// 代理合约
contract Proxy {
    // 逻辑合约地址，在代理合约初始化会赋值
    // 同时，在实现合约中， 状态变量的声明顺序必须保持和代理合约中一致
    address public implementation;

    // 构造函数
    constructor(address implementation_) {
        implementation = implementation_;
    }

    // 回调函数，
    fallback() external payable {
        _delegate();
    }

    // 实际的代码调用
    function _delegate() internal {
        // 使用内联汇编
        assembly {
            // 获取逻辑合约地址
            let _implementation := sload(0)

            // 拷贝数据
            calldatacopy(0, 0, calldatasize())

            // 调用
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // 将结果复制到内存中
            returndatacopy(0, 0, returndatasize())

            // 如果执行出错，result=0，如果执行成功，result=1
            switch result

            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}


// 逻辑合约，状态变量的声明必须与代理合约中保持一致
contract Logic {
    address public implementation;

    uint public x = 99;

    event CallSuccess();


    function increment() external returns(uint) {
        emit CallSuccess();

        return x + 1;
    } 
}


// 调用合约
contract Caller {
    address public proxy;

    event CallSuccess(bool success, bytes data);

    constructor(address proxy_) {
        proxy = proxy_;
    }

    function increment() external returns(uint) {
        (bool success, bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));

        emit CallSuccess(success, data);

        return abi.decode(data, (uint));
    }
}