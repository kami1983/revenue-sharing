// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleTest {
    string public message;
    
    constructor() {
        message = "Hello, Asset-Hub Westend!";
    }
    
    function setMessage(string memory _message) public {
        message = _message;
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
} 