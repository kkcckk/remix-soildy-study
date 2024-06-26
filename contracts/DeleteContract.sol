// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
    selfdestruct, 在EIP-6049，可以删除合约并转移合约剩余的ETH
    在以太坎昆(Cancun)升级中，即EIP-6780，减少了SELFDESTRUCT操作码的功能，只可以转移剩余的ETH，
    而删除功能，只有在创建合约-自毁这两个操作处在同一笔交易中才能生效。

    使用方式：selfdestruct(_addr);
        _addr必须是paybale address类型的，因为要用这个地址来接收ETH
*/
contract DeleteContract {
    uint public value = 10;

    constructor() payable {}

    receive() external payable { }

    function deleteContract() external {
        selfdestruct(payable(msg.sender));
    }

    function getBalance() external view returns(uint balance) {
        balance = address(this).balance;
    }
}