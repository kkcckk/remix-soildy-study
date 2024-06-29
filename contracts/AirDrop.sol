// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";

/**
    关于在合约中函数的参数什么时候应该用memory，什么时候应该用calldata
    memory：
    1. 当需要在函数中修改传递的参数时，应使用memory。
    2. 当数据需要在函数内部被多次访问和操作时，使用memory更为合适。
    3. 如果需要对传入的数据进行复杂计算或处理，通常会使用memory。

    calldata：
    1. 当函数参数只是被读取而不需要修改时，使用calldata可以节省Gas。
    2. 特别适用于公共或外部函数中的数组或结构体参数，因为这种情况下calldata更加高效。
*/
contract AirDrop{
    // 记录空投失败地址映射关系
    mapping (address => uint256) public failTransferList;

    // 计算空投的总数
    function getSum(uint256[] calldata _arr) internal pure returns(uint256 _sum) {
        for(uint i=0; i<_arr.length; i++) {
            _sum += _arr[i];
        }
    }

    // 向多个地址发送代币
    // 有一个地址池和一个token数量池，每个地址的代币数量不一致，也就说最终每个撸空投用户获取的代币数量也不一样
    function multiTransferToken(
        address tokenContract,
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external {
            // 首先，一个地址对应一个amount
            require(_addresses.length == _amounts.length, "The length of addresses and amount is not equal");

            // 创建代币
            IERC20 erc20= IERC20(tokenContract);

            uint256 _amountSum = getSum(_amounts);

            // 发送的空投的总数应当小于代币授权的数量
            require(erc20.allowance(msg.sender, address(this)) > _amountSum, "allowance is less than amountSum");

            // 给每个地址授权一定数量的token数量
            for(uint i = 0; i < _addresses.length; i++) {
                // 调用合约的用户也就是代币的拥有者，给授权的地址发送一定数量的代币
                // 供其他用户撸空投使用
                erc20.transferFrom(msg.sender, _addresses[i], _amounts[i]);
            }
        }

    // 向每个地址发送ETH，也就是给每个用户开始发放空投
    function mulitiTransferETH(
        // 可以接收转账的地址
        address payable[] calldata _addresses,
        uint[] calldata _amounts
    ) public payable {
        // 首先确保每个地址都能获得
        require(_addresses.length == _amounts.length, "The length of _addresses and _amounts is not equal.");

        // 获取转账的代币总和
        uint256 amountSum = getSum(_amounts);

        // 代币总和和转入的总和一致
        require(amountSum == msg.value, "amountSum is not equal to msg.value");

        // 开始转账
        // 转账是使用call，不要使用transfer
        for(uint256 i = 0; i < _addresses.length; i++) {
            (bool success, ) = _addresses[i].call{value: _amounts[i]}("");

            if (!success) {
                failTransferList[_addresses[i]] = _amounts[i];
            }
        }
    }
}

/**
     总结一下空投的逻辑:
        1. 首先部署好代币
        2. 铸币
        3. 部署空投合约
        4. 调用代币的approve函数给空投地址授权代币数量，即给空投合约地址转入对应的可用代币
        5. 开始发送代币，调用transferFrom()函数，使用代理地址进行转账
        6. 转账完成后，可以通过balancesOf进行查询余额

    注意的点：
        得弄明白msg.sender和address(this)之间的关系
        目前来看，在airdrop合约中address(this)是空投合约的地址
        msg.sender是调用合约的地址，两者还是有区别的

        在remix中，我使用的是这个地址去部署erc20币的：0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        得到的erc20币的地址是0xd9145CCE52D386f254917e481eB44e9943F39138，同时执行mint铸币：10000个

        在使用这个地址去部署AirDrop合约：0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        得到的AirDrop合约地址：0xf8e81D47203A594245E36C48e151709F0C19fBe8

        两个合约部署完成之后，需要使用erc20代币去给AriDrop合约授权可以使用的代币，调用approve(AriDrop地址, 10000),
        此时通过调用allowance，传入代币拥有者地址，即部署erc20时的地址：0x5B38Da6a701c568545dCfcB03FcB875f56beddC4，传入被委托者地址，即AirDrop地址：0xf8e81D47203A594245E36C48e151709F0C19fBe8，
        可以看见可以使用的委托代币的数量是10000

        AirDrop已经授权成功之后，开始发放空投，调用multiTransferToken，传入erc20地址：0xd9145CCE52D386f254917e481eB44e9943F39138，
        传入地址数组["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"],
        代币数量组[200,300]

        发送成功后，通过balanceOf，依次输入["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]两个地址，可以看见余额分别是200和300，
        同时使用allowance查询owner：0x5B38Da6a701c568545dCfcB03FcB875f56beddC4和被授权地址：0xf8e81D47203A594245E36C48e151709F0C19fBe8，看见授权可用代币数量由10000-->9500
*/