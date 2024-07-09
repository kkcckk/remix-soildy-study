// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;


/**
    分账合约：
    1. 在创建合约时定好分账受益人payees和每人的份额shares。
    2. 份额可以是相等，也可以是其他任意比例。
    3. 在该合约收到的所有ETH中，每个受益人将能够提取与其分配的份额成比例的金额。
    4. 分账合约遵循Pull Payment模式，付款不会自动转入账户，而是保存在此合约中。受益人通过调用release()函数触发实际转账。
*/
contract PaymentSolit {
    // 事件：增加收益人事件、受益人提款事件、分账合约收款事件
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    // 总份额
    uint256 public totalShares;
    // 总支付
    uint256 public totalReleased;

    // 用来映射每个受益人对应的比例
    mapping (address => uint256) public shares;
    // 每个受益人已提出的收益
    mapping (address => uint256) public released;
    // 用来保存受益人地址
    address[] public payees;

    // 在构造器中初始化受益人数组和收益系数
    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        // 收益人数组长度和收益系数数组要相同，并且payees_和shares_中的元数都不能为0
        require(_payees.length == _shares.length, "The length of payees_ and shares_ is not equal.");
        // 必须要有受益人
        require(_payees.length > 0, "no payees");

        // 开始初始化
        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    // 合约收钱，释放合约收钱事件
    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    // 受益人收钱
    function release(address payable account) public virtual {
        // 必须是有收益的
        require(shares[account] > 0, "The account has not pay shares");

        // 计算收益
        uint256 amount = releasable(account);

        // 收益必须大于0
        require(amount > 0, "Insufficient account limit");

        // 先改变状态，防止双花
        released[account] += amount;
        totalReleased += amount;

        // 进行转账
        (bool success,) = account.call{value: amount}("");

        // 触发事件
        if (success) {
            emit PaymentReleased(account, amount);
        } else {
            revert("Transfer failed");
        }
        
    }

    function releasable(address account) public view returns(uint256) {
        // 找出合约的总额
        uint256 totalReceived = address(this).balance + totalReleased;

        // 收益人能获取份额
        return (totalReceived * shares[account]) / totalShares - released[account];
    }

    // 增加受益人以及收益金额
    function _addPayee(address account, uint256 accountShare) private {
        // 地址不能是address(0)， accountShare必须大于0
        require(account != address(0), "The account can't be zero address.");
        require(accountShare > 0, "The accountShare must be greater than zero");
        require(shares[account] == 0, "The account can't be duplicate");

        // 加入地址列表
        payees.push(account);
        // 加入地址映射收益比例
        shares[account] = accountShare;
        // 总收益
        totalShares += accountShare;

        emit PayeeAdded(account, accountShare);
    }
}