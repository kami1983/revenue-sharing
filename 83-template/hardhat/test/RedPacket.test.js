const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RedPacket", function() {
  let RedPacket;
  let SimpleERC20;
  let redPacket;
  let token;
  let owner;
  let user1;
  let user2;
  
  const tokenName = "Test Token";
  const tokenSymbol = "TST";
  const tokenDecimals = 18;
  const initialSupply = 1000000; // 1,000,000 tokens
  const packetAmount = ethers.utils.parseUnits("100", 18); // 100 tokens
  const password = "GOODLUCK";
  
  beforeEach(async function() {
    // Get contract factories
    RedPacket = await ethers.getContractFactory("RedPacket");
    SimpleERC20 = await ethers.getContractFactory("SimpleERC20");
    
    // Get signers
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy the ERC20 token
    token = await SimpleERC20.deploy(tokenName, tokenSymbol, tokenDecimals, initialSupply);
    await token.deployed();
    
    // Deploy the RedPacket contract
    redPacket = await RedPacket.deploy();
    await redPacket.deployed();
    
    // Approve the RedPacket contract to spend tokens
    await token.approve(redPacket.address, packetAmount);
  });
  
  describe("Creating Red Packets", function() {
    it("should create a red packet and emit event", async function() {
      // Create a red packet
      const tx = await redPacket.createPacket(token.address, packetAmount, password);
      
      // Verify the transaction emits the PacketCreated event
      await expect(tx)
        .to.emit(redPacket, "PacketCreated")
        .withArgs(1, owner.address, token.address, packetAmount);
      
      // Verify red packet info
      const packetInfo = await redPacket.getPacketInfo(1);
      
      expect(packetInfo.creator).to.equal(owner.address);
      expect(packetInfo.tokenAddress).to.equal(token.address);
      expect(packetInfo.totalAmount).to.equal(packetAmount);
      expect(packetInfo.remainingAmount).to.equal(packetAmount);
      expect(packetInfo.claimedCount).to.equal(0);
      expect(packetInfo.isValid).to.equal(true);
    });
    
    it("should fail to create a red packet with zero amount", async function() {
      await expect(
        redPacket.createPacket(token.address, 0, password)
      ).to.be.revertedWith("Amount must be greater than 0");
    });
    
    it("should fail to create a red packet with invalid token address", async function() {
      await expect(
        redPacket.createPacket(ethers.constants.AddressZero, packetAmount, password)
      ).to.be.revertedWith("Invalid token address");
    });
  });
  
  describe("Claiming Red Packets", function() {
    let packetId;
    
    beforeEach(async function() {
      // Create a red packet first
      const tx = await redPacket.createPacket(token.address, packetAmount, password);
      const receipt = await tx.wait();
      packetId = 1;
    });
    
    it("should claim a red packet with correct password", async function() {
      // Check initial balance
      const initialBalance = await token.balanceOf(user1.address);
      
      // Claim the red packet
      const tx = await redPacket.connect(user1).claimPacket(packetId, password);
      
      // Verify the transaction emits the PacketClaimed event
      await expect(tx)
        .to.emit(redPacket, "PacketClaimed")
        .withArgs(packetId, user1.address, packetAmount);
      
      // Verify user1's balance has increased
      const finalBalance = await token.balanceOf(user1.address);
      expect(finalBalance.sub(initialBalance)).to.equal(packetAmount);
      
      // Verify red packet status
      const packetInfo = await redPacket.getPacketInfo(packetId);
      expect(packetInfo.remainingAmount).to.equal(0);
      expect(packetInfo.claimedCount).to.equal(1);
      expect(packetInfo.isValid).to.equal(false);
    });
    
    it("should fail to claim with incorrect password", async function() {
      await expect(
        redPacket.connect(user1).claimPacket(packetId, "WRONGPASSWORD")
      ).to.be.revertedWith("Incorrect password");
    });
    
    it("should fail to claim an already claimed red packet", async function() {
      // First claim is successful
      await redPacket.connect(user1).claimPacket(packetId, password);
      
      // Second claim should fail
      await expect(
        redPacket.connect(user2).claimPacket(packetId, password)
      ).to.be.revertedWith("Packet does not exist or is invalid");
    });
    
    it("should fail to claim a non-existent red packet", async function() {
      await expect(
        redPacket.connect(user1).claimPacket(999, password)
      ).to.be.revertedWith("Packet does not exist or is invalid");
    });
  });
  
  describe("Emergency Withdrawal", function() {
    let packetId;
    
    beforeEach(async function() {
      // Create a red packet first
      await redPacket.createPacket(token.address, packetAmount, password);
      packetId = 1;
    });
    
    it("should allow owner to withdraw tokens in emergency", async function() {
      // Check initial balance
      const initialBalance = await token.balanceOf(owner.address);
      
      // Emergency withdraw
      await redPacket.emergencyWithdraw(token.address, packetAmount);
      
      // Verify owner's balance has increased
      const finalBalance = await token.balanceOf(owner.address);
      expect(finalBalance.sub(initialBalance)).to.equal(packetAmount);
    });
    
    it("should not allow non-owner to withdraw tokens", async function() {
      await expect(
        redPacket.connect(user1).emergencyWithdraw(token.address, packetAmount)
      ).to.be.revertedWithCustomError(redPacket, "OwnableUnauthorizedAccount")
      .withArgs(user1.address);
    });
  });
}); 