// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RedPacket
 * @dev A contract that allows users to create, claim and query red packets
 */
contract RedPacket is Ownable {
    // Red packet structure
    struct Packet {
        address creator;         // Creator of the red packet
        address tokenAddress;    // Token address
        uint256 totalAmount;     // Total amount
        uint256 remainingAmount; // Remaining amount
        uint256 claimedCount;    // Number of claims
        uint256 createdTime;     // Creation time
        bool isValid;            // Is valid
        bytes32 passwordHash;    // Password hash
    }
    
    // Mapping from packet ID to packet info
    mapping(uint256 => Packet) public packets;
    
    // Current packet ID
    uint256 private nextPacketId = 1;
    
    // Events
    event PacketCreated(uint256 indexed packetId, address indexed creator, address tokenAddress, uint256 amount);
    event PacketClaimed(uint256 indexed packetId, address indexed claimer, uint256 amount);
    
    /**
     * @dev Constructor
     */
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Create a red packet
     * @param tokenAddress Token address
     * @param amount Amount of tokens
     * @param password Password (plaintext)
     * @return Packet ID
     */
    function createPacket(address tokenAddress, uint256 amount, string memory password) external returns (uint256) {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");
        
        // Transfer tokens to contract
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        
        // Calculate password hash
        bytes32 passwordHash = keccak256(abi.encodePacked(password));
        
        // Create packet
        uint256 packetId = nextPacketId;
        packets[packetId] = Packet({
            creator: msg.sender,
            tokenAddress: tokenAddress,
            totalAmount: amount,
            remainingAmount: amount,
            claimedCount: 0,
            createdTime: block.timestamp,
            isValid: true,
            passwordHash: passwordHash
        });
        
        // Increment ID counter
        nextPacketId++;
        
        // Emit event
        emit PacketCreated(packetId, msg.sender, tokenAddress, amount);
        
        return packetId;
    }
    
    /**
     * @dev Claim a red packet
     * @param packetId Packet ID
     * @param password Password (plaintext)
     * @return Amount claimed
     */
    function claimPacket(uint256 packetId, string memory password) external returns (uint256) {
        // Validate packet
        Packet storage packet = packets[packetId];
        require(packet.isValid, "Packet does not exist or is invalid");
        require(packet.remainingAmount > 0, "Packet is empty");
        
        // Validate password
        bytes32 passwordHash = keccak256(abi.encodePacked(password));
        require(passwordHash == packet.passwordHash, "Incorrect password");
        
        // Calculate claim amount (simplified to claim all)
        uint256 claimAmount = packet.remainingAmount;
        
        // Update packet state
        packet.remainingAmount = 0;
        packet.claimedCount += 1;
        
        // If empty, mark as invalid
        if (packet.remainingAmount == 0) {
            packet.isValid = false;
        }
        
        // Transfer tokens
        IERC20 token = IERC20(packet.tokenAddress);
        require(token.transfer(msg.sender, claimAmount), "Token transfer failed");
        
        // Emit event
        emit PacketClaimed(packetId, msg.sender, claimAmount);
        
        return claimAmount;
    }
    
    /**
     * @dev Get packet information
     * @param packetId Packet ID
     * @return creator Creator address
     * @return tokenAddress Token address
     * @return totalAmount Total amount
     * @return remainingAmount Remaining amount
     * @return claimedCount Number of claims
     * @return createdTime Creation time
     * @return isValid Is valid
     */
    function getPacketInfo(uint256 packetId) external view returns (
        address creator,
        address tokenAddress,
        uint256 totalAmount,
        uint256 remainingAmount,
        uint256 claimedCount,
        uint256 createdTime,
        bool isValid
    ) {
        Packet storage packet = packets[packetId];
        return (
            packet.creator,
            packet.tokenAddress,
            packet.totalAmount,
            packet.remainingAmount,
            packet.claimedCount,
            packet.createdTime,
            packet.isValid
        );
    }
    
    /**
     * @dev Emergency withdrawal of tokens by the owner
     * @param tokenAddress Token address
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner(), amount), "Token transfer failed");
    }
} 