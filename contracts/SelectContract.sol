// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


/**
    函数签名就是函数名称带上参数类型的字符串："函数名称(参数类型1, 参数类型2, 参数类型3,...)",
    在同一个合约中，不同的函数的函数签名是不一样的，所以合约中是用函数签名来区分函数的

    方法id method id：就是函数签名的keccak256之后的前四个byte：bytes4(keccak256("函数名(参数类型1, 参数类型2, ...)"))，
    当selector和method id能匹配上时，就会调用对应的函数

    注意的点，int和uint在函数签名中要写为int256和uint256
*/
contract SelectContract {
    event Log(address addr, bytes data);
    event SelectorEvent(bytes4 methodId);
    event CallWithSignatureEvent(string title, bool success, bytes data);

    // 定义mapping、结构体、枚举类型
    struct User {
        uint256 uid;
        bytes name;
    }

    enum School {
        SCHOOL1,
        SCHOOL2,
        SCHOOL3
    }

    // 基础参数类型
    function mint(address to) external {
        emit Log(to, msg.data); 
    }


    // 固定长度参数类型
    function fixedSizeParamSelector(uint p) external returns(bytes4 methodId) {
        emit SelectorEvent(this.fixedSizeParamSelector.selector);
        methodId = calculateMintSignature("fixedSizeParamSelector(uint256)");
        delete p;
    }

    // 可变长度参数类型
    function noFiexdSizeParamSelector(uint256[2] memory p1, string memory p2) external returns(bytes4 methodId) {
        emit SelectorEvent(this.noFiexdSizeParamSelector.selector);
        // 多个参数时，使用逗号分隔不能加空格，否则解析出来的methodId会和实际的不一致
        methodId = calculateMintSignature("noFiexdSizeParamSelector(uint256[2],string)");
        delete p1;
        delete p2;
    }

    /**
        映射类型参数，结构体类型参数，枚举类型参数（底层实现是基于uint8实现的），合约类型参数
        合约类型参数转化为address
        结构体类型参数转化为tuple
        枚举类型参数转化为uint8
    */
    function mixedParamSelector(User memory user, School school) external returns(bytes4 methodId) {
        emit SelectorEvent(this.mixedParamSelector.selector);
        methodId = calculateMintSignature("mixedParamSelector((uint256,bytes),uint8)");
        delete user;
        delete school;
    }

    // 用来计算函数method id
    function calculateMintSignature(string memory funSignature) public pure returns(bytes4 methodId) {
        methodId = bytes4(keccak256(abi.encodePacked(funSignature)));
    }

    // 使用selector调用函数，配合call一起使用
    function callWithSignature() external {
        // 初始化uint256数组
        uint256[] memory param1 = new uint256[](3);
        param1[0] = 1;
        param1[1] = 2;
        param1[2] = 3;

        // 初始化struct
        User memory user;
        user.uid = 1;
        user.name = "0xa0b1";

        School s = School.SCHOOL1;

        // 固定长度参数类型
        (bool successFixed, bytes memory dataFixed) = address(this).call(abi.encodeWithSelector(calculateMintSignature("fixedSizeParamSelector(uint256)"), 1));
        emit CallWithSignatureEvent("fixedSizeParamSelector", successFixed, dataFixed);

        // 可变长度参数类型
        (bool successNoFixed, bytes memory dataNoFixed) = address(this).call(abi.encodeWithSelector(calculateMintSignature("noFiexdSizeParamSelector(uint256[2],string)"), [1,2], "noFixed"));
        emit CallWithSignatureEvent("noFixedSizeParamSelector", successNoFixed, dataNoFixed);
        
        
        // 映射参数类型
        (bool successMapping, bytes memory dataMapping) = address(this).call(abi.encodeWithSelector(calculateMintSignature("mixedParamSelector((uint256,bytes),uint8)"), user, s));
        emit CallWithSignatureEvent("mixedParamSelector", successMapping, dataMapping);
    }
}
