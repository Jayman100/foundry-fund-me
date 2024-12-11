// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    // To avoid having change the way we want to deploy our contract in two place
    // here and test file , We can deploy it in deploy file and return so that
    // we can just access this contract in test file then call the function that
    // return the contract that we are deploying..

    function run() external returns (FundMe) {
        // This helper config helps to get the active network address
        // Doing this before starting the broadcast means that we don not
        // want to send it as a tx ,so it will not cost any gas )()

        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeedAddress = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe deployFundMe = new FundMe(ethUsdPriceFeedAddress);
        vm.stopBroadcast();

        return deployFundMe;
    }
}
