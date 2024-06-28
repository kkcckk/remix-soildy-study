// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

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


/** 
    1. 首先开发代币合约，上面已经开发完成
    2. 之后再部署代币，获取代币的地址
    3. 再开发代币水龙头合约
    4. 部署的代币水龙头合约的时候，需要给构造器传入第2步部署好的代币地址
    5. 部署好代币水龙头之后，需要给这个代币水龙头转入一定的代币数量，所以使用代币.transfer(代币水龙头地址, 转账代币数量)进行转账
    6. 之后就从这个代币水龙头中获取代币
*/
contract Faucet {
    // 每次获取成功都需要触发一下事件
    event SendToken(address sender, uint256 amountAllowed);

    // 每次允许获取的代币数量，直接初始化，想给多少就给多少
    uint256 public amountAllowed = 100;
    
    // 代币的地址，初始化代币水龙头时传入
    address tokenContract;

    // 代币合约
    IERC20 private _erc20;

    // 映射关系，记录哪些地址是否获取代币
    mapping (address => bool) public requestAddress;

    constructor(address tokenContract_) {
        // 水龙头初始化时，同时也创建对应的代币
        _erc20 = IERC20(tokenContract_);
    }

    // 开始请求领取代币
    function requestToken() external {
        // 首先调用者不能重复获取代币
        require(!requestAddress[msg.sender], "Can't obtain tokens multiple times");

        // 判断数量，如果当前水龙头的代币数量不足amountAllow，则提示代币不足
        require(_erc20.balanceOf(address(this)) >= amountAllowed, "Faucet is empty");

        // 开始转移代币，每次领取100个
        _erc20.transfer(msg.sender, amountAllowed);

        // 记录领取的地址
        requestAddress[msg.sender] = true;

        // 触发事件
        emit SendToken(msg.sender, amountAllowed);

    }
}