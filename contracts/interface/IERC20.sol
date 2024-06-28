// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
*   @dev ERC20接口
*/
interface IERC20 {
    /**
        indexed
            1. 索引参数：通过使用indexed关键字，事件参数将被索引。这意味着这些参数的值可以在事件日志中进行快速搜索和过滤。
            2. 提高查询效率：索引参数可以显著提高查询效率，因为它允许通过特定值快速查找相关事件。这在处理大量数据时尤为重要。
            3. 最多三个索引：一个事件最多可以有三个indexed参数。这是因为索引操作会消耗更多的Gas，限制索引参数的数量可以帮助控制成本。
        
        用户进行转账的时候触发的事件
    */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /** 
        进行授权的时候触发的事件
    */
    event Approval(address indexed from, address indexed spender, uint256 value);


    // 返回代币的总量
    function totalSupply() external view returns(uint256);

    // 返回指定账户的余额
    function balanceOf(address account) external view returns(uint256);

    // 进行点对点转账
    function transfer(address to, uint256 value) external returns(bool);

    // 返回授权账户的余额
    function allowance(address owner, address spender) external view returns(uint256);

    // 进行授权
    function approve(address spender, uint256 value) external returns(bool);

    // 使用代理地址进行转账
    function transferFrom(address from, address to, uint256 value) external returns(bool);
}