// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// 库合约就相当于java大神写的工具类类似，只管拿来直接使用
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
        @dev Convert a `uint256` to its ASCII `string` decimal representation
    */
    function toString(uint256 value) internal pure returns(string memory) {
        // 如果value=0，直接返回
        if (value == 0) {
            return "0";
        }

        // 临时变量
        uint256 temp = value;
        
        // 创建一个动态字节数组，到时候将数字先转换位字节数组，之后转换位字符串string
        // 这个变量就是动态字节数组的长度
        uint256 digits;

        while (temp != 0) {
            digits ++;
            temp /= 10;
        }

        // 创建动态字节数组
        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


contract LibraryStudy {
    /**
        使用using A for B,可以使得库合约附加（从库A）到任意类型（类型B）。
        添加完之后，库合约中的函数会自动变为类型B变量的成员，即次类型的变量可以随意调用库合约中的任意函数
    */
    using Strings for uint256;

    function numToString(uint256 _num) public pure returns(string memory) {
        // 这种调用方式，会自动把_num当作参数传入
        // return _num.toString();

        // 也可以使用库合约.库函数(参数)的方式调用
        return Strings.toString(_num);
    }
}