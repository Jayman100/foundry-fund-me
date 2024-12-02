// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

//Custom error

// Convention -> Contract name__error name

error FundMe__NotOwner();

contract FundMe {
    //Attaching priceConverter  to uint256

    using PriceConverter for uint256;

    //What to do :
    // - Get funds from users

    //Constant and immutable keywords for gas efficiency
    uint256 public constant MINIMUM_USD = 5 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountSend;

    address public immutable i_owner;

    // For easy deployment like if we choose to deploy to another chain
    // it is not good to have our chain contract address hardcoded in
    // our code ;

    AggregatorV3Interface private s_priceFeed;

    //Constructor get called immediately the contract is deployed
    // priceFeed_address is the chain price feed address from chainlink
    constructor(address priceFeed_address) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed_address);
    }

    function fund() public payable {
        //Want to be able to set a minimum fund amount in USD
        //1. How do we send ETH to this contract?

        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ether"
        ); //This sets the minimum ether to send
        funders.push(msg.sender);
        addressToAmountSend[msg.sender] += msg.value;

        // what is reverting?
        //undo any action before and send the remaining gas back
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    // - Withdraw funds

    function withdraw() public onlyOwner {
        // - Set a minimum funding value in USD

        // for loop
        // Starting index, ending index, step

        //resetting fund back to zero
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];

            addressToAmountSend[funder] = 0;
        }
        //reset array (funders)
        funders = new address[](0);

        //Three ways to send ether:
        //- transfer

        //the "this" keyword means the address of the whole contract

        // payable(msg.sender) = payable address type
        // we need it because we want to sender ether
        // This will revert if transaction failed
        //    payable ( msg.sender).transfer(address(this).balance);

        //- send
        // This returns boolean and the can only be revert when failed if use with require.

        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        //- call
        // this returns two variables which are boolean(if failed or succeed) and
        // data(bytes) if we include function instead of blank("")

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    //Modifiers are use to add features to a function.
    //this onlyOwner modifier makes  a function callable
    //only by the owner of the contract
    //- the underscore(_) means the rest of the code ,
    // and it can be before the code or after .

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");

        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //What happens if someone send this contract
    //ETH without calling the fund function ?

    // There are 2 special functions that can help us with that;
    // recieve(), and

    receive() external payable {
        fund();
    }

    //fallback()

    fallback() external payable {
        fund();
    }
}
