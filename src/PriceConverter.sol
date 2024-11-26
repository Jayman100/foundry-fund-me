//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
//Library : smart contract with functionality that is
// reusable across other contracts to avoid code repetition.
// - Library can not have any state variable
// - They can not send any ether as well
// - all functions have to be internal(not public)

library PriceConverter {
    function getPrice() internal view returns (uint256) {
        //What we need to interact with a contract outside this project:
        // ABI
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306 -> Sepolia ETH/USD aggregator CA

        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        //Price of ETh in USD
        (, int256 price, , , ) = priceFeed.latestRoundData();

        //Typecasting- To convert price to uint 256 from int256 to match the msg.value which is uint256
        //We need to convert it because the msg.value is in uint256
        return uint256(price * 1e10);
    }

    function version() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return priceFeed.version();
    }

    function getConversionRate(
        uint256 ethAmount
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice();

        // We need to divide the product of ethPrice and ethAmount by 1e18
        // because after both have 1e18 i.e(1000000000000000000), which when multiplied
        // will give us 1e36 and we only need 1e18

        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}
