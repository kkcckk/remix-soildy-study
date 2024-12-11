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

    // 列表
    uint256[] public listOfFavoriteNumbers;

    // 人列表
    Person[] public persons;

    // 创建结构体
    struct Person {
        string name;
        uint256 age;
    }

    // 创建函数
    function store(uint256 _defaultNumber) public {
        defaultNumber = _defaultNumber;
    }

    // calldata修饰的变量不可被修改
    function createPerson(string calldata _name, uint256 _age) public {
        Person memory p = Person(_name, _age);
        persons.push(p);
    }

    // map不能被循环，但是可以理用list去变量map中的数据
}