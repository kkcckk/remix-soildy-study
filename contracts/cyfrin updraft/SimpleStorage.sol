// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // solidity的版本，并且版本大于等于18

contract SimpleStorage {
    // 基础类型 boolean uint int address bytes

    // 创建变量
    bool hasFavoriteNumber = false;

    // 无符号整型
    uint favoriteNumer = 88;

    // 有符号整型
    int favoritePositiveNumber = -88;

    // 默认值 整型都是0 布尔型是false
    uint256 public defaultNumber;

    // 创建函数
    function store(uint256 _defaultNumber) public {
        defaultNumber = _defaultNumber;
    }
}