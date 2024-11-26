// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    // first function is setUp function and it is use to deploy contract
    // setUp function is always the first to run
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();
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

        assertEq(fundMe.i_owner(), address(this));
    }
}
