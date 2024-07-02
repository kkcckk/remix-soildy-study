// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


library MerkleProof {
    // 计算hash值
    function _hash(bytes32 a, bytes32 b) internal pure returns(bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    // 计算根节点
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns(bytes32) {
        bytes32 root = leaf;

        for(uint i=0; i < proof.length; i++) {
            root = _hash(root, proof[i]);
        }

        return root;
    }

    // 证明传入的leaf节点的值在merkel树中
    function verify(bytes32[] memory proof, bytes32 leaf, bytes32 root) internal pure returns(bool) {
        return processProof(proof, leaf) == root;
    }
}