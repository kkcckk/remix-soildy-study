// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interface/IERC20.sol";


// 简化版本ERC20
contract ERC20 is IERC20 {
    // 用来存放地址的余额
    mapping(address => uint256) public override balanceOf;

    // 用来存放地址和代理地址的映射关系以及代理地址对应的余额
    mapping(address => mapping(address => uint256)) public override allowance;

    // 代币的总额
    uint256 public override totalSupply;

    // 代币名称
    string public name;

    // 代币的符合
    string public symbol;

    // 展示金额显示的小数位数
    uint8 public decimals = 18;

    // 构造器，针对名称和符合进行赋值，这个些一旦创建，不可修改
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 进行点对点转账
    function transfer(address to, uint256 value) public override returns(bool) {
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        
        return true;
    }

    // 进行授权
    function approve(address spender, uint256 value) public override returns(bool) {
        address owner = msg.sender;
        allowance[owner][spender] = value;

        emit Approval(owner, spender, value);

        return true;
    }

    // 使用授权地址进行转账
    function transferFrom(address from, address to, uint256 value) public override returns(bool) {
        // 代理账户调用这个函数
        address spender = msg.sender;

        // 代理账户余额减少value
        // 真实的要判断代理账户的余额是不是和uint256的最大值相等
        allowance[from][spender] -= value;

        // 主账户余额也要相应的减少
        balanceOf[from] -= value;
        
        // 收款方金额加
        balanceOf[to] += value;

        emit Transfer(from, to, value);

        return true;
    }

    // 铸币
    function mint(uint256 value) external {
        balanceOf[msg.sender] += value;
        totalSupply += value;

        emit Transfer(address(0), msg.sender, value);
    }

    // 销毁币
    function burn(uint256 value) external {
        balanceOf[msg.sender] -= value;
        totalSupply -= value;

        emit Transfer(msg.sender, address(0), value);
    }
}