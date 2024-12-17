// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // 获取以太坊的价格
    function getPrice() internal view returns(uint256) {
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return uint256(price * 1e10);
    }

    // 获取转化率
    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        //  获取以太的价格，用美元换算
        uint256 ethPrice = getPrice();
        // 计算转化率
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e10;
        return ethAmountInUsd;
    }
}