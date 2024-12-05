// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // first function is setUp function and it is use to deploy contract
    // setUp function is always the first to run
    FundMe fundMe;

    // Create a fake address just for testing
    address USER = makeAddr("jayman");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Accsessing the deploy function and calling the run function to
        //have access to the contract deployed

        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // vm.deal is used to fund an address with new balance (fake)
        // for testing

        vm.deal(USER, STARTING_BALANCE);
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
        console.log(fundMe.getOwner());

        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();

        console.log(fundMe.getVersion());
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        /**
         * The expectRevert method tell us that the next line must fail
         * for this test to pass, if the next line is valid then this test will
         * fail
         */
        vm.expectRevert();

        // The fund() function will fail if it is called without a value and value
        // in eth should be more than $5
        fundMe.fund(); // This is sending 0 value
    }

    modifier funded() {
        vm.prank(USER); // The next transaction will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        _;
    }

    // vm.prank allow us to explicitly set address we want use for next transaction
    // in testing
    function testFundUpdatesFundedDataStructure() public funded {
        // vm.prank(USER); // The next transaction will be sent by USER
        // fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArrayOfFunders() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMebalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(newAddress) ;
            // vm.deal to fund the new address
            // But there hoax function that can perform both prank and deal

            // As address(0) = 0x000000000000000..; we can also generate address
            // from other numbers too like address(2), address(1) ;
            // as of solidity v0.8 we the need number to be used for the to be
            // uint160
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMebalance,
            fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(newAddress) ;
            // vm.deal to fund the new address
            // But there hoax function that can perform both prank and deal

            // As address(0) = 0x000000000000000..; we can also generate address
            // from other numbers too like address(2), address(1) ;
            // as of solidity v0.8 we the need number to be used for the to be
            // uint160
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert

        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMebalance,
            fundMe.getOwner().balance
        );
    }
}
