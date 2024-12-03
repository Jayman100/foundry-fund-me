//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

//TODO: 1. Deploy mocks when we are on a local anvil chain
//TODO: 2. Keep track of contract address across different chains

contract HelperConfig is Script {
    // If we are on local chain (anvil), we deploy mocks
    // Otherwise , grab the existing address from live network

    // This is to hold active Network we are so we can use in deployment
    NetworkConfig public activeNetworkConfig;

    uint8 public constant ETH_DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // We need to check if we have created a priceFeedAddress before,
        // to avoid creating twice. if the priceFeedAddress is not invalid
        // then just return it.

        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks -> mock contract is like a dummy contract
        // 2. Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            ETH_DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: address(mockPriceFeed)
        });

        return anvilConfig;
    }
}
