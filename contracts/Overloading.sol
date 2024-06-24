// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "hardhat/console.sol";


contract Overloading {
    /**
        重载：solidity允许函数进行重载（overloading），即名字相同但输入参数
        类型不同的函数可以同时存在。和java的重载是一样的。
        注意：修饰器（modifier）不允许重载
    */
    function saySomething() public pure returns(string memory) {
        return ("Nothing");
    }

    function saySomething(string memory something) public pure returns(string memory) {
        return something;
    }

    /**
        注意：在调用重载函数时，会把输入的实际参数的类型和函数参数的类型做匹配。
        如果出现多个匹配的函数会报错，就比如一个合约中，有两个相同名称的函数构成重载函数，
        一个参数类型为uint8，一个参数类型为uint16，
        假设调用函数，并传入参数为50时，会同时匹配类型uint8和uint16，所以不知道是调用哪个函数，
        因此会报错
    */
    function f(uint8 _n) public pure returns(uint8 out) {
        out = _n;
    }

    function f(uint16 _n) public pure returns(uint16 out) {
        out = _n;
    }

    // 如果调用函数f(50),会同时匹配上f(uint8 _n)和f(uint16 _n)
}