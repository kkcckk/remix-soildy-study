// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


/**
    封装ETH，在ERC20的基础上新增加了两个函数，存钱和取钱。
    常见的不止WETH，也有WBTC WBNB
    封装以后，这些代币可以用于Dapp或者跨链
*/

contract WETH is ERC20 {
    // 事件：存款和取款
    event Deposit(address indexed dst, uint wad);
    event Withdrawal(address indexed src, uint wad, bool success);

    constructor() ERC20("KX", "KX") {

    }

    // 转账触发fallback函数和receive函数
    fallback() external payable {
        // 接收到钱了触发存款函数
        deposit();
    }
    receive() external payable {
        // 接收到钱了触发存款函数
        deposit();
    }

    // 存款函数
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // 取款函数
    function withdrawal(uint amount) public {
        require(balanceOf(msg.sender) > amount, "insufficient balance");
        _burn(msg.sender, amount);
        (bool success,) = payable(msg.sender).call{value: amount}("");
        emit Withdrawal(msg.sender, amount, success);
    }
}