// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title RedPacketLite
 * @dev A lightweight red packet contract without OpenZeppelin's Ownable
 */
contract RedPacketLite {
    // Owner address (replaces Ownable)
    address public owner;
    
    // Red packet structure
    struct Packet {
        address creator;
        address tokenAddress;
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 claimedCount;
        uint256 createdTime;
        bool isValid;
        bytes32 passwordHash;
    }
    
    // Mapping from packet ID to packet info
    mapping(uint256 => Packet) public packets;
    
    // Current packet ID
    uint256 private nextPacketId = 1;
    
    // Events
    event PacketCreated(uint256 indexed packetId, address indexed creator, address tokenAddress, uint256 amount);
    event PacketClaimed(uint256 indexed packetId, address indexed claimer, uint256 amount);
    
    // Custom errors to save gas
    error NotOwner();
    error InvalidTokenAddress();
    error AmountTooLow();
    error TransferFailed();
    error InvalidPacket();
    error PacketEmpty();
    error IncorrectPassword();
    
    /**
     * @dev Constructor sets the owner to msg.sender
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Modifier to check if caller is owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    /**
     * @dev Create a red packet
     * @param tokenAddress Token address
     * @param amount Amount of tokens
     * @param password Password (plaintext)
     * @return Packet ID
     */
    function createPacket(address tokenAddress, uint256 amount, string calldata password) external returns (uint256) {
        if (tokenAddress == address(0)) revert InvalidTokenAddress();
        if (amount == 0) revert AmountTooLow();
        
        // Transfer tokens to contract
        if (!IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        
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
    function claimPacket(uint256 packetId, string calldata password) external returns (uint256) {
        // Validate packet
        Packet storage packet = packets[packetId];
        if (!packet.isValid) revert InvalidPacket();
        if (packet.remainingAmount == 0) revert PacketEmpty();
        
        // Validate password
        if (keccak256(abi.encodePacked(password)) != packet.passwordHash) revert IncorrectPassword();
        
        // Calculate claim amount (simplified to claim all)
        uint256 claimAmount = packet.remainingAmount;
        
        // Update packet state
        packet.remainingAmount = 0;
        packet.claimedCount += 1;
        packet.isValid = false;
        
        // Transfer tokens
        if (!IERC20(packet.tokenAddress).transfer(msg.sender, claimAmount)) revert TransferFailed();
        
        // Emit event
        emit PacketClaimed(packetId, msg.sender, claimAmount);
        
        return claimAmount;
    }
    
    /**
     * @dev Get packet information
     * @param packetId Packet ID
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
        if (!IERC20(tokenAddress).transfer(owner, amount)) revert TransferFailed();
    }
    
    /**
     * @dev Transfer ownership to a new address
     * @param newOwner New owner address
     */
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidTokenAddress();
        owner = newOwner;
    }
} 