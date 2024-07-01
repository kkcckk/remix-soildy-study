// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IERC721Metadata.sol";

contract TestKx {
    function calcSelector() public pure returns(bytes4) {
        return bytes4(IERC721Metadata.name.selector ^ IERC721Metadata.symbol.selector ^ IERC721Metadata.tokenURI.selector);
    }
}