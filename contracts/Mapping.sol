// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
/**
    在映射中，如果是一个mapping(address => 结构体)，
    如果查询一个不存在的key，那么返回的是一个拥有默认值的结构体
*/
contract Mapping {
    mapping(uint => address) public idToAddress; // id映射到地址
    mapping(address => address) public swapPair; // 币对的映射，地址到地址
    
    // 规则1. _KeyType不能是自定义的 下面这个例子会报错
    // 我们定义一个结构体 Struct
    struct Student{
       uint256 id;
       uint256 score; 
    }
    // mapping(Struct => uint) public testVar;
    mapping (uint => Student) public studentMapping;

    function writeMap (uint _Key, address _Value) public{
        idToAddress[_Key] = _Value;
    }


    function getStudent(uint tokenId) public returns(Student memory) {
        Student storage s = studentMapping[tokenId];

        s.id = tokenId;
        s.score = tokenId + 1;

        return s;
    }
}