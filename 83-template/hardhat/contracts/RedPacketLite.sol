// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RedPacketLite {
    address public owner;
    
    struct Packet {
        address creator;
        address token;
        uint256 amount;
        bool claimed;
        bytes32 pwdHash;
    }
    
    mapping(uint256 => Packet) public packets;
    uint256 private nextId = 1;
    uint256 private locked;
    
    event Created(uint256 id, address creator, address token, uint256 amount);
    event Claimed(uint256 id, address claimer, uint256 amount);
    
    error NotOwner();
    error InvalidArgs();
    error AlreadyClaimed();
    error WrongPassword();
    error TransferFailed();
    error Locked();
    
    constructor() { owner = msg.sender; }
    
    modifier safe() {
        if(locked > 0) revert Locked();
        locked = 1;
        _;
        locked = 0;
    }
    
    function createPacket(address token, uint256 amount, string calldata pwd) external safe returns(uint256) {
        if(token == address(0) || amount == 0) revert InvalidArgs();
        
        (bool success,) = token.call(
            abi.encodeWithSelector(0x23b872dd, msg.sender, address(this), amount)
        );
        if(!success) revert TransferFailed();
        
        uint256 id = nextId++;
        packets[id] = Packet({
            creator: msg.sender,
            token: token,
            amount: amount,
            claimed: false,
            pwdHash: keccak256(abi.encodePacked(pwd))
        });
        
        emit Created(id, msg.sender, token, amount);
        return id;
    }
    
    function claimPacket(uint256 id, string calldata pwd) external safe returns(uint256) {
        Packet storage packet = packets[id];
        
        if(packet.token == address(0)) revert InvalidArgs();
        if(packet.claimed) revert AlreadyClaimed();
        if(keccak256(abi.encodePacked(pwd)) != packet.pwdHash) revert WrongPassword();
        
        packet.claimed = true;
        
        (bool success,) = packet.token.call(
            abi.encodeWithSelector(0xa9059cbb, msg.sender, packet.amount)
        );
        if(!success) revert TransferFailed();
        
        emit Claimed(id, msg.sender, packet.amount);
        return packet.amount;
    }
    
    function emergencyWithdraw(address token, uint256 amount) external {
        if(msg.sender != owner) revert NotOwner();
        
        (bool success,) = token.call(
            abi.encodeWithSelector(0xa9059cbb, owner, amount)
        );
        if(!success) revert TransferFailed();
    }
    
    function getPacketInfo(uint256 id) external view returns(
        address creator,
        address token,
        uint256 amount,
        bool claimed
    ) {
        Packet storage packet = packets[id];
        return (packet.creator, packet.token, packet.amount, packet.claimed);
    }
    
    function transferOwnership(address newOwner) external {
        if(msg.sender != owner) revert NotOwner();
        if(newOwner == address(0)) revert InvalidArgs();
        owner = newOwner;
    }
} 