const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RedPacketLite", function() {
  let RedPacketLite;
  let SimpleERC20;
  let redPacketLite;
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
    RedPacketLite = await ethers.getContractFactory("RedPacketLite");
    SimpleERC20 = await ethers.getContractFactory("SimpleERC20");
    
    // Get signers
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy the ERC20 token
    token = await SimpleERC20.deploy(tokenName, tokenSymbol, tokenDecimals, initialSupply);
    await token.deployed();
    
    // Deploy the RedPacketLite contract
    redPacketLite = await RedPacketLite.deploy();
    await redPacketLite.deployed();
    
    // Approve the RedPacketLite contract to spend tokens
    await token.approve(redPacketLite.address, packetAmount);
  });
  
  describe("Creating Red Packets", function() {
    it("should create a red packet and emit event", async function() {
      // Create a red packet
      const tx = await redPacketLite.createPacket(token.address, packetAmount, password);
      
      // Verify the transaction emits the Created event
      await expect(tx)
        .to.emit(redPacketLite, "Created")
        .withArgs(1, owner.address, token.address, packetAmount);
      
      // Verify red packet info
      const packetInfo = await redPacketLite.getPacketInfo(1);
      
      expect(packetInfo.creator).to.equal(owner.address);
      expect(packetInfo.token).to.equal(token.address);
      expect(packetInfo.amount).to.equal(packetAmount);
      expect(packetInfo.claimed).to.equal(false);
    });
    
    it("should fail to create a red packet with zero amount", async function() {
      await expect(
        redPacketLite.createPacket(token.address, 0, password)
      ).to.be.revertedWithCustomError(redPacketLite, "InvalidArgs");
    });
    
    it("should fail to create a red packet with invalid token address", async function() {
      await expect(
        redPacketLite.createPacket(ethers.constants.AddressZero, packetAmount, password)
      ).to.be.revertedWithCustomError(redPacketLite, "InvalidArgs");
    });
  });
  
  describe("Claiming Red Packets", function() {
    let packetId;
    
    beforeEach(async function() {
      // Create a red packet first
      const tx = await redPacketLite.createPacket(token.address, packetAmount, password);
      const receipt = await tx.wait();
      packetId = 1;
    });
    
    it("should claim a red packet with correct password", async function() {
      // Check initial balance
      const initialBalance = await token.balanceOf(user1.address);
      
      // Claim the red packet
      const tx = await redPacketLite.connect(user1).claimPacket(packetId, password);
      
      // Verify the transaction emits the Claimed event
      await expect(tx)
        .to.emit(redPacketLite, "Claimed")
        .withArgs(packetId, user1.address, packetAmount);
      
      // Verify user1's balance has increased
      const finalBalance = await token.balanceOf(user1.address);
      expect(finalBalance.sub(initialBalance)).to.equal(packetAmount);
      
      // Verify red packet status
      const packetInfo = await redPacketLite.getPacketInfo(packetId);
      expect(packetInfo.claimed).to.equal(true);
    });
    
    it("should fail to claim with incorrect password", async function() {
      await expect(
        redPacketLite.connect(user1).claimPacket(packetId, "WRONGPASSWORD")
      ).to.be.revertedWithCustomError(redPacketLite, "WrongPassword");
    });
    
    it("should fail to claim an already claimed red packet", async function() {
      // First claim is successful
      await redPacketLite.connect(user1).claimPacket(packetId, password);
      
      // Second claim should fail
      await expect(
        redPacketLite.connect(user2).claimPacket(packetId, password)
      ).to.be.revertedWithCustomError(redPacketLite, "AlreadyClaimed");
    });
    
    it("should fail to claim a non-existent red packet", async function() {
      await expect(
        redPacketLite.connect(user1).claimPacket(999, password)
      ).to.be.revertedWithCustomError(redPacketLite, "InvalidArgs");
    });
  });
  
  describe("Emergency Withdrawal", function() {
    let packetId;
    
    beforeEach(async function() {
      // Create a red packet first
      await redPacketLite.createPacket(token.address, packetAmount, password);
      packetId = 1;
    });
    
    it("should allow owner to withdraw tokens in emergency", async function() {
      // Check initial balance
      const initialBalance = await token.balanceOf(owner.address);
      
      // Emergency withdraw
      await redPacketLite.emergencyWithdraw(token.address, packetAmount);
      
      // Verify owner's balance has increased
      const finalBalance = await token.balanceOf(owner.address);
      expect(finalBalance.sub(initialBalance)).to.equal(packetAmount);
    });
    
    it("should not allow non-owner to withdraw tokens", async function() {
      await expect(
        redPacketLite.connect(user1).emergencyWithdraw(token.address, packetAmount)
      ).to.be.revertedWithCustomError(redPacketLite, "NotOwner");
    });
  });
  
  describe("Ownership", function() {
    it("should allow owner to transfer ownership", async function() {
      // Transfer ownership to user1
      await redPacketLite.transferOwnership(user1.address);
      
      // Verify new owner
      expect(await redPacketLite.owner()).to.equal(user1.address);
      
      // Verify user1 can now call owner-only functions
      await token.transfer(user1.address, packetAmount);
      await token.connect(user1).approve(redPacketLite.address, packetAmount);
      await redPacketLite.connect(user1).emergencyWithdraw(token.address, 0);
    });
    
    it("should not allow non-owner to transfer ownership", async function() {
      await expect(
        redPacketLite.connect(user1).transferOwnership(user2.address)
      ).to.be.revertedWithCustomError(redPacketLite, "NotOwner");
    });
    
    it("should not allow transferring ownership to zero address", async function() {
      await expect(
        redPacketLite.transferOwnership(ethers.constants.AddressZero)
      ).to.be.revertedWithCustomError(redPacketLite, "InvalidArgs");
    });
  });
}); 