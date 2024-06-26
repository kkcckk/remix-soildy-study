// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


/**
    函数签名就是函数名称带上参数类型的字符串："函数名称(参数类型1, 参数类型2, 参数类型3,...)",
    在同一个合约中，不同的函数的函数签名是不一样的，所以合约中是用函数签名来区分函数的

    方法id method id：就是函数签名的keccak256之后的前四个byte：bytes4(keccak256("函数名(参数类型1, 参数类型2, ...)"))，
    当selector和method id能匹配上时，就会调用对应的函数

    注意的点，int和uint在函数签名中要写为int256和uint256
*/
contract SelectContract {
    event Log(address addr, bytes data);


    function mint(address to) external {
        emit Log(to, msg.data);
    }


    function calculateMintSignature() external pure returns(bytes4 methodId) {
        return bytes4(keccak256("mint(address)"));
    }
}