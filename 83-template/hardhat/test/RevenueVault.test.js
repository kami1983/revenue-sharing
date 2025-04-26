const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("RevenueVault", function () {
  // 我们定义一个部署fixture，以便在多个测试中重用相同的设置
  async function deployRevenueVaultFixture() {
    // 获取一些测试账户
    const [owner, account1, account2] = await ethers.getSigners();

    // 部署 RevenueVault 合约
    const RevenueVault = await ethers.getContractFactory("RevenueVault");
    const revenueVault = await RevenueVault.deploy();
    await revenueVault.deployed();

    // 部署 MockUSDC 合约
    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const mockUSDC = await MockUSDC.deploy();
    await mockUSDC.deployed();

    // 获取合约地址 (ethers v5)
    const revenueVaultAddress = revenueVault.address;
    const mockUSDCAddress = mockUSDC.address;

    // 添加 USDC 到支持的代币列表
    await revenueVault.addSupportedToken(mockUSDCAddress);

    // 向测试账户转移一些 USDC
    await mockUSDC.transfer(account1.address, ethers.utils.parseUnits("1000", 6));
    await mockUSDC.transfer(account2.address, ethers.utils.parseUnits("1000", 6));

    return { revenueVault, mockUSDC, owner, account1, account2, revenueVaultAddress, mockUSDCAddress };
  }

  describe("部署", function () {
    it("应成功部署合约", async function () {
      const { revenueVaultAddress, mockUSDCAddress } = await loadFixture(deployRevenueVaultFixture);
      expect(revenueVaultAddress).to.not.equal("0x0000000000000000000000000000000000000000");
      expect(mockUSDCAddress).to.not.equal("0x0000000000000000000000000000000000000000");
    });

    it("应将 USDC 添加到支持的代币列表", async function () {
      const { revenueVault, mockUSDCAddress } = await loadFixture(deployRevenueVaultFixture);
      expect(await revenueVault.supportedTokens(1)).to.equal(mockUSDCAddress);
    });
  });

  describe("铸造 Vault NFT", function () {
    it("应允许用户铸造 NFT", async function () {
      const { revenueVault, account1 } = await loadFixture(deployRevenueVaultFixture);
      await revenueVault.connect(account1).mint(1, { value: ethers.utils.parseEther("0.01") });
      expect(await revenueVault.balanceOf(account1.address)).to.equal(1);
      expect(await revenueVault.ownerOf(1)).to.equal(account1.address);
    });

    it("应拒绝不充足的 ETH 支付", async function () {
      const { revenueVault, account1 } = await loadFixture(deployRevenueVaultFixture);
      await expect(
        revenueVault.connect(account1).mint(1, { value: ethers.utils.parseEther("0.005") })
      ).to.be.revertedWith("Insufficient ETH sent");
    });
  });

  describe("收益分配", function () {
    it("应正确分配 ETH 收益", async function () {
      const { revenueVault, revenueVaultAddress, owner, account1, account2 } = await loadFixture(deployRevenueVaultFixture);
      
      // 铸造 NFT
      await revenueVault.connect(account1).mint(10, { value: ethers.utils.parseEther("0.1") });
      await revenueVault.connect(account2).mint(10, { value: ethers.utils.parseEther("0.1") });
      
      // 发送 ETH 到合约
      await owner.sendTransaction({
        to: revenueVaultAddress,
        value: ethers.utils.parseEther("2.0")
      });
      
      // 检查余额
      const initialBalance = await ethers.provider.getBalance(account1.address);
      
      // 领取奖励
      await revenueVault.connect(account1).claim(ethers.constants.AddressZero);
      
      // 检查是否收到了奖励
      const newBalance = await ethers.provider.getBalance(account1.address);
      
      // account1 应该收到 2.0 * (10/20) = 1.0 ETH，减去 gas 费
      // 我们只需要检查余额是否增加
      expect(newBalance.gt(initialBalance)).to.be.true;
    });

    it("应正确分配 USDC 收益", async function () {
      const { revenueVault, mockUSDC, revenueVaultAddress, mockUSDCAddress, owner, account1, account2 } = await loadFixture(deployRevenueVaultFixture);
      
      // 铸造 NFT
      await revenueVault.connect(account1).mint(10, { value: ethers.utils.parseEther("0.1") });
      await revenueVault.connect(account2).mint(10, { value: ethers.utils.parseEther("0.1") });
      
      // 发送 USDC 到合约
      const usdcAmount = ethers.utils.parseUnits("200", 6); // 200 USDC
      await mockUSDC.transfer(revenueVaultAddress, usdcAmount);
      
      // 触发分配
      await revenueVault.connect(account1).triggerDistribution(mockUSDCAddress);
      
      // 检查初始余额
      const initialBalance = await mockUSDC.balanceOf(account1.address);
      
      // 领取奖励
      await revenueVault.connect(account1).claim(mockUSDCAddress);
      
      // 检查新余额
      const newBalance = await mockUSDC.balanceOf(account1.address);
      
      // account1 应该收到 200 * (10/20) = 100 USDC
      const expectedReward = ethers.utils.parseUnits("100", 6);
      const acceptableMargin = ethers.utils.parseUnits("1", 6);
      expect(newBalance.sub(initialBalance).sub(expectedReward).abs().lte(acceptableMargin)).to.be.true;
    });
  });

  describe("查询奖励", function () {
    it("应正确返回可领取的奖励", async function () {
      const { revenueVault, mockUSDC, revenueVaultAddress, mockUSDCAddress, owner, account1, account2 } = await loadFixture(deployRevenueVaultFixture);
      
      // 铸造 NFT
      await revenueVault.connect(account1).mint(10, { value: ethers.utils.parseEther("0.1") });
      await revenueVault.connect(account2).mint(10, { value: ethers.utils.parseEther("0.1") });
      
      // 发送 USDC 到合约
      const usdcAmount = ethers.utils.parseUnits("200", 6); // 200 USDC
      await mockUSDC.transfer(revenueVaultAddress, usdcAmount);
      
      // 触发分配
      await revenueVault.connect(account1).triggerDistribution(mockUSDCAddress);
      
      // 获取 account1 持有的第一个代币 ID
      const tokenId = await revenueVault.tokenOfOwnerByIndex(account1.address, 0);
      
      // 检查可领取的奖励
      const pendingReward = await revenueVault.pendingReward(mockUSDCAddress, tokenId);
      expect(pendingReward.gt(0)).to.be.true;
      
      // 检查总的可领取奖励
      const pendingRewardAll = await revenueVault.pendingRewardAll(mockUSDCAddress, account1.address);
      // account1 持有 10 个 NFT，每个 NFT 应分得约 10 USDC
      const expectedReward = ethers.utils.parseUnits("100", 6);
      const acceptableMargin = ethers.utils.parseUnits("1", 6);
      expect(pendingRewardAll.sub(expectedReward).abs().lte(acceptableMargin)).to.be.true;
    });
  });
}); 