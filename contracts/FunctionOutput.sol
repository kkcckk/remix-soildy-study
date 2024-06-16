// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract FunctionOutput {
    function returnMulitiple() public pure returns(uint256, bool, uint256[3] memory) {
        // 如果在returns中没有写变量名，要使用return这种方式返回
        return (1, true, [uint256(1), 2, 3]);
    }

    function returnNamed() public pure returns(uint256 a, bool b, uint256[3] memory c) {
        /** 如果在returns中写了变量名，编译器在编译的时候会自动创建并初始化同名变量
            即以下三行代码
            uint 256 a;
            bool b;
            uint256[3] memory c;
            同时自动返回这几个变量的值
            即自动省略了return(a, b, c) 这段代码
            或者也可以直接返回对应的值，请看returnNamed2()函数
        */
        a = 2;
        b = true;
        c = [uint256(1), 2, 3];
    }

    function returnNamed2() public pure returns(uint256 a, bool b, uint256[3] memory c) {
        /** 如果在returns中写了变量名，编译器在编译的时候会自动创建并初始化同名变量
            即以下三行代码
            uint 256 a;
            bool b;
            uint256[3] memory c;
            同时自动返回这几个变量的值
            即自动省略了return(a, b, c) 这段代码
            或者也可以直接返回对应的值，请看returnNamed2()函数
        */
        return (1, true, [uint256(1), 2, 3]);
    }

    // 读取返回值
    function readReturn() public pure {
        uint256 a;
        bool b;
        uint256[3] memory c;

        // 读取全部返回值
        (a, b, c) = returnNamed();

        // 读取部分返回值
        (, b, c) = returnNamed();
    }
}