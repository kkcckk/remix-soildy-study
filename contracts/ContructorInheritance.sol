// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract A {
    uint256 public a;
    constructor(uint256 _a){
        a = _a;
    }
}

contract B is A {
    constructor(uint _b) A(_b * _b){

    }
}