// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PolkaVMTest
 * @dev A simple test contract for deployment and testing on PolkaVM
 */
contract PolkaVMTest {
    string private greeting;
    mapping(address => uint256) private balances;
    
    event GreetingChanged(address indexed changer, string newGreeting);
    event Deposited(address indexed depositor, uint256 amount);
    
    constructor() {
        greeting = "Hello, PolkaVM!";
    }
    
    /**
     * @dev Set a new greeting
     * @param _greeting The new greeting
     */
    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
        emit GreetingChanged(msg.sender, _greeting);
    }
    
    /**
     * @dev Get the current greeting
     * @return The current stored greeting
     */
    function getGreeting() public view returns (string memory) {
        return greeting;
    }
    
    /**
     * @dev Allow users to deposit funds
     */
    function deposit() public payable {
        require(msg.value > 0, "Must deposit some funds");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    /**
     * @dev Get the balance of a user
     * @param user The user address to query
     * @return The balance of the user
     */
    function balanceOf(address user) public view returns (uint256) {
        return balances[user];
    }
    
    /**
     * @dev Get the contract balance
     * @return The balance of the contract
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
} 