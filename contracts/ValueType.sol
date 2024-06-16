// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ValueType{
    // bool type & bool calculate
    bool public _bool = true;
    bool public _bool1 = !_bool; // false
    bool public _bool2 = _bool && _bool1; // false 
    bool public _bool3 = _bool || _bool1; // true
    bool public _bool4 = _bool == _bool1; // false
    bool public _bool5 = _bool != _bool1; // true


    // number type & number calculate
    int public _int = -1;
    uint public _uint = 1;
    uint256 public _number = 20240615;
    uint256 public _number1 = _number + 1;
    uint256 public _number2 = 2**2;
    uint256 public _number3 = 7 % 2;
    bool public _numberBool = _number2 > _number3;

    // address type
    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    // transform to payable address
    address payable public _address1 = payable(_address);

    // fix length byte array
    bytes32 public _bytes32 = "study soility";
    bytes1 public _byte = _bytes32[0];

    // enumerate type & transform to uint
    enum Action { up, down, left, right}
    Action a = Action.down;

    function enumToInt() external view returns(uint) {
        return uint(a);
    }
}