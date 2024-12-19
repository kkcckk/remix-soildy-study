// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMathTester {
    // 在0.8.0以前，uint和int类型的变量都是unchecked
    // 在solidity 0.8.0版本以上，会自动对变量执行溢出或下溢的检查
    // 如果不想对该变量进行检查，可以使用关键字uncheck
    uint8 public bigNumber = 255;

    function add() public {
        bigNumber = bigNumber + 1; // 会自行进行上溢和下溢检查
        // unchecked {
            // bigNumber = bigNumber + 1; // unchecked修饰的变量就不会进行上溢和下溢检查
        // }
    }
}