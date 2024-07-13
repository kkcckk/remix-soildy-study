// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
    时间锁：通过时间管控，对代币进行锁定，等时间到了可以安全的交易
    也可以提前取消交易，但是只有管理员或者时间合约才能进行操作，时间合约默认是管理员的身份
*/


contract TimeLocker {
    /**
        四个事件：
            1. 创建交易事件，交易会进入交易队列中
            2. 取消交易事件，交易从交易队列去剔除
            3. 执行交易事件，锁定期满后，会执行交易
            4. 修改管理员地址事件
    */
    event QueueTransaction(bytes32 txHash, address indexed target, uint256 amount, string signature, bytes data, uint executeTime);
    event CancelTransaction(bytes32 txHash, address indexed target, uint256 amount, string signature, bytes data, uint executeTime);
    event ExecuteTransaction(bytes32 txHash, address indexed target, uint256 amount, string signature, bytes data, uint executeTime);
    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    /**
        状态变量：
            管理员地址 address public adminAddress
            延迟时间：在一定的延迟时间之后，才可以进行交易操作 uint256 public delay
            交易有效期，在到达延迟之间之后，多长时间范围内交易是有效的 uint256 public constant GRACE_PERIOD
            记录交易的映射 mapping(bytes32 => bool) public queueTransactions;
    */
    address public adminAddress;
    uint256 public delay;
    uint256 public constant GRACE_PERIOD = 7 days;
    mapping (bytes32 => bool) public queueTransactions;

    /**
        权限修饰符：
            1. 只允许时间锁合约的地址进行操作，时间锁管理员相当于超级管理员
            2. 只允许管理员操作
    */
    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "TimeLock:: Caller must be admin");
    }

    modifier onlyTimeLock() {
        require(msg.sender == address(this), "Timelock:: Caller must be Timelock");
    }

    // 构造器，初始化延迟时间和管理员
    constructor(uint256 delay_, address adminAddress_) {
        adminAddress = adminAddress_;
        delay = delay_;
    }

    // 获取时间戳
    function getBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    // 计算交易id值，通过地址、金额、签名数据、callData数据以及执行时间进行hash
    function getTxHash(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 executeTime
        ) public view returns(bytes32) {
            return keccak256(abi.encodePacked(target, value, signature, data, executeTime));
    }

    // 创建交易
    function queueTransaction(address target, uint256 amount, string memory signature, bytes memory bytes data, uint256 executeTime) public onlyAdmin returns(bytes32){
        // 执行时间必须大于当前的区块时间
        require(executeTime >= getBlockTimestamp(), "The execution time must be greater then block.timestamp.");

        // 计算交易哈希
        bytes32 txHash = getTxHash(target, amount, signature, data, executeTime);

        // 加入交易队列
        queueTransactions[txHash] = true;

        // 触发事件
        emit QueueTransaction(txHash, target, amount, signature, data, executeTime);

        // 返回交易哈希
        return txHash;
    }

    // 取消交易
    function cancelTransaction(address target, uint256 amount, string memory signature, bytes memory data, executeTime) public onlyAdmin returns(bytes32) {
        bytes32 txHash = getTxHash(target, amount, signature, data, executeTime);

        queueTransactions[txHash] = false;

        // 触发事件
        emit CancelTransaction(txHash, target, amount, signature, data, executeTime);

        return bytes32;
    }

    // 执行交易
    function executeTransaction(address target, uint256 amount, string memory signature, bytes memory data, executeTime) public onlyAdmin returns(bytes memory) {
        // 判断交易是否在交易队列中
        bytes32 txHash = getTxHash(target, amount, signature, data, executeTime);
        require(queueTransactions[txHash], "Timelock::executeTransaction: The transaction is not in the queue");

        // 判断时间是否到期
        require(executeTime <= getBlockTimestamp(), "Timelock::executeTransaction: The transaction has not yet reached the execution time.");

        // 判断交易有效期是否过期
        require(getBlockTimestamp() <= executeTime + GRACE_PERIOD,  "Timelock::executeTransaction: Transaction is stale.");

        // 获取call data
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory data) = target.call{value: amount}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, amount, signature, data, executeTime);

        return data;
    }
}