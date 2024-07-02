// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
    数字签名步骤
    1. 先对数据进行哈希，使用keccak256函数
    2. 在进行以太坊签名，使用'\x19Ethereum Signed Message:\n32'和哈希后的数据再进行一次哈希
    3. 签名
        - 利用钱包签名，常用的是metamask，进行签名的时候只需要输入钱包的地址和消息，就可以进行签名
        - 利用web3.py签名，利用python代码签名，请见py文件夹中signature_with_web3.py文件
    4. 验证签名，利用消息hash和签名，解析出公钥，与实际的公钥做对比，验证签名是否正确，‘
       使用的是RSV签名算法去验证(Recovery ID(v), Signature(s, r))
            r: 签名的前 32 字节。
            s: 签名的后 32 字节。
            v: 恢复标志，用于恢复签名者的公钥。通常为 27 或 28。
*/


library ECDSA {
     // 验证签名，参数：哈希之后的消息（含有以太消息头部），签名，公钥（签名地址）
     function _verify(bytes32 _msgHash, bytes memory _signature, address _signer) internal pure returns(bool) {
        return recoverSign(_msgHash, _signature) == _signer;
     }

     // 解析公钥，参数：哈希之后的消息，签名
     function recoverSign(bytes32 _msgHash, bytes memory _signature) internal pure returns(address) {
        // 签名的长度是65
        require(_signature.length==65, "Invalid signature.");

        // 使用rsv
        bytes32 r;
        bytes32 s;
        bytes1 v;

        // 使用汇编获取r、s、v的值
        assembly {
            r := mload(add(_signature, "0x20"))
            s := mload(add(_signature, "0x40"))
            v := byte(0, mload(add(_signature, "0x90")))
        }

        return ecrecover(_msgHash, v, r, s);
     }

     // 使用以太消息头部和哈希之后的消息进行哈希
     function toEthSignedMessageHash(bytes32 hash) public pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
     }
}