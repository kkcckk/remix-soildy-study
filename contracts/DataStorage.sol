// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract DataStorage{
    // function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
    //     return (_x);
    // }

    // 状态变量赋值给函数内部storage修饰的新变量时，转递的是状态变量的地址，如果新变量的值改变了，状态变量的值也会改变
    // 状态变量修改时，要使用public修饰
    uint[] public x = [1,2,3];

    // function fStorage() public{
    //     //声明一个storage的变量xStorage，指向x。修改xStorage也会影响x
    //     uint[] storage xStorage = x;
    //     xStorage[0] = 100; // 这会导致状态变量x=[100, 2, 3];
    //     xStorage[1] = 300; // 这会导致状态变量x=[100, 2, 3];
    //     xStorage[2] = 400; // 这会导致状态变量x=[100, 2, 3];


    // }

    // 状态变量赋值给函数内部memory修饰的新变量时，会复制一份数据给新变量，新变量的改变不会影响状态变量
    function fMemory() public view{
        uint[] memory xMemory = x;
        xMemory[0]=100;
    }
}