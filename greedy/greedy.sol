// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GreedyContract {
    address public owner;
    uint public balance;

    constructor() {
        owner = msg.sender;
    }

    // Function to receive Ether
    receive() external payable {
        balance += msg.value;
    }

    // Function to withdraw all Ether by the owner
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        require(balance > 0, "No balance to withdraw");
        
        uint amountToWithdraw = balance;
        balance = 0;
        
        (bool success, ) = msg.sender.call{value: amountToWithdraw}("");
        require(success, "Withdrawal failed");
    }

    // Vulnerable function that can be called by an attacker
    function maliciousFunction() public {
        // Perform some actions
        
        // Now, call the withdraw function to drain the contract
        withdraw();
    }
}
