// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; // solidity的版本，并且版本大于等于18

contract SimpleStorage {
    // // 基础类型 boolean uint int address bytes

    // // 创建变量
    // bool hasFavoriteNumber = false;

    // // 无符号整型
    // uint favoriteNumer = 88;

    // // 有符号整型
    // int favoritePositiveNumber = -88;

    // // 默认值 整型都是0 布尔型是false
    // uint256 public defaultNumber;

    // // 列表
    // uint256[] public listOfFavoriteNumbers;

    // // 人列表
    // Person[] public persons;

    // // 创建结构体
    // struct Person {
    //     string name;
    //     uint256 age;
    // }

    // // 创建函数
    // function store(uint256 _defaultNumber) public {
    //     defaultNumber = _defaultNumber;
    // }

    // // calldata修饰的变量不可被修改
    // function createPerson(string calldata _name, uint256 _age) public {
    //     Person memory p = Person(_name, _age);
    //     persons.push(p);
    // }

    // // map不能被循环，但是可以理用list去变量map中的数据
    uint256 myFavoriteNumber;

    struct Person {
        uint256 favoriteNumber;
        string name;
    }
    // uint256[] public anArray;
    Person[] public listOfPeople;

    mapping(string => uint256) public nameToFavoriteNumber;

    // 加上了virtual的函数可以被子类重写
    function store(uint256 _favoriteNumber) public virtual {
        myFavoriteNumber = _favoriteNumber;
    }

    function retrieve() public view returns (uint256) {
        return myFavoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        listOfPeople.push(Person(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}


contract SimpleStorage2 {}

contract SimpleStorage3 {}

contract SimpleStorage4 {}