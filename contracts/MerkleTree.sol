// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import  "./library/MerkleProof.sol";
import "./ERC721.sol";

/**
    使用白名单发放NFT，其中，名单是已经确认了的，所有可以通过这分名单，计算出Merkle Tree的root，
    所有在合约的构造器中，会存放一份，并且无法修改
*/
contract MerkleTree is ERC721 {
    // 根节点，在构造器中赋值
    bytes32 immutable private root;

    // 记录已经发放过的地址
    mapping (address => bool) public mintedAddresses;

    constructor(string memory name, string memory symbol, bytes32 mekrleRoot) ERC721(name, symbol) {
        root = mekrleRoot;
    }

    // 首先确认传入的地址是在白名单中
    function _verify(bytes32 leaf, bytes32[] memory proof) internal view returns(bool) {
        return MerkleProof.verify(proof, leaf, root);
    }

    // 计算地址的哈希值
    function _leaf(address account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    // 开始铸币
    function mint(address account, uint256 tokenId, bytes32[] memory proof) external {
        // 首先要求地址在白名单中
        require(_verify(_leaf(account), proof), "The account dose not exist in the whitelist");

        // 之前没有领过
        require(!mintedAddresses[account], "The account has aleady received the token.");

        // 开始铸币
        _mint(account, tokenId);

        // 记录领取过的地址
        mintedAddresses[account] = true;
    }
}