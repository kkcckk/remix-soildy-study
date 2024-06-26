// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
    abi应用
        编码的函数：
        1. abi.encode
        2. abi.encodePacked
        3. abi.encodeWithSignature
        4. abi.encodeWithSelector

        解码的函数，用于解码abi.encode的数据：
        1. abi.decode

    使用场景
    1. 配合call一起使用，调用对方合约代码
    2. ethers.js中常用ABI实现合约的导入和函数调用
    3. 对不开源合约进行反编译后，某些函数无法查到函数签名，可通过ABI进行调用
*/
contract ABIContract {
    uint x = 10;
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    string name = "0xAA";
    uint[2] array = [5, 6];

    function encode() public view returns(bytes memory result) {
        result = abi.encode(x, addr, name, array);
    }

    function encodePacked() public view returns(bytes memory result) {
        result = abi.encodePacked(x, addr, name, array);
    }

    function encodeWithSignture() public view returns(bytes memory result) {
        result = abi.encodeWithSignature("fun(uint256, address, string, uint256[2]", x, addr, name, array);
    }

    function encodeWithSelector() public view returns(bytes memory result) {
        result = abi.encodeWithSelector(bytes4(keccak256("fun(uint256, address, string, uint256[2])")), x, addr, name, array);
    }

    function decode(bytes memory data) public pure returns(uint dx, address daddr, string memory dname, uint[2] memory darray) {
        (dx, daddr, dname, darray) = abi.decode(data, (uint256, address, string, uint256[2]));
    }
}