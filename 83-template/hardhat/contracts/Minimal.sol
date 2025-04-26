// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Minimal {
    string public constant greeting = "Hello, Asset-Hub!";
    
    function greet() public pure returns (string memory) {
        // Hello, Asset-Hub!
        return greeting;
    }
} 