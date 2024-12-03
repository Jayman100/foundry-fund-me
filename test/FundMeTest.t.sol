// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // first function is setUp function and it is use to deploy contract
    // setUp function is always the first to run
    FundMe fundMe;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Accsessing the deploy function and calling the run function to
        //have access to the contract deployed

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    // Is it important to prefix all test functions with test ? Yes
    // All test functions needs to be prefix with test
    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    // FundMeTest contract is the one that deploy the fundMe contract
    // not me , So doing assertEq(fundMe.i_owner(), msg.sender); will always fail
    // because msg.sender is my address not the contract address -> address(this)

    function testOwnerIsMsgSender() public {
        console.log(msg.sender);
        console.log(fundMe.i_owner());

        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();

        console.log(fundMe.getVersion());
        assertEq(version, 4);
    }
}
