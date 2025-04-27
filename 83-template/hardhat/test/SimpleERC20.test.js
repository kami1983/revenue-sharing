const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleERC20", function() {
  let SimpleERC20;
  let token;
  let owner;
  let addr1;
  let addr2;
  
  const tokenName = "Simple Token";
  const tokenSymbol = "ST";
  const tokenDecimals = 18;
  const initialSupply = 1000000; // 1,000,000 tokens
  
  beforeEach(async function() {
    // 获取合约工厂
    SimpleERC20 = await ethers.getContractFactory("SimpleERC20");
    
    // 获取测试账户
    [owner, addr1, addr2] = await ethers.getSigners();
    
    // 部署合约
    token = await SimpleERC20.deploy(tokenName, tokenSymbol, tokenDecimals, initialSupply);
    await token.deployed();
  });
  
  describe("部署", function() {
    it("应正确设置代币的基本信息", async function() {
      expect(await token.name()).to.equal(tokenName);
      expect(await token.symbol()).to.equal(tokenSymbol);
      expect(await token.decimals()).to.equal(tokenDecimals);
      
      const totalSupplyBN = await token.totalSupply();
      expect(totalSupplyBN.toString()).to.equal(ethers.utils.parseUnits(initialSupply.toString(), tokenDecimals).toString());
    });
    
    it("应将所有代币分配给部署者", async function() {
      const ownerBalanceBN = await token.balanceOf(owner.address);
      const totalSupplyBN = await token.totalSupply();
      expect(ownerBalanceBN.toString()).to.equal(totalSupplyBN.toString());
    });
  });
  
  describe("交易", function() {
    it("应能在账户之间转移代币", async function() {
      // 从owner转移100个代币到addr1
      const transferAmount = ethers.utils.parseUnits("100", tokenDecimals);
      await token.transfer(addr1.address, transferAmount);
      
      // 检查addr1的余额
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance.toString()).to.equal(transferAmount.toString());
      
      // 从addr1转移50个代币到addr2
      const halfAmount = transferAmount.div(2);
      await token.connect(addr1).transfer(addr2.address, halfAmount);
      
      // 检查最终余额
      const addr2Balance = await token.balanceOf(addr2.address);
      const addr1FinalBalance = await token.balanceOf(addr1.address);
      
      expect(addr2Balance.toString()).to.equal(halfAmount.toString());
      expect(addr1FinalBalance.toString()).to.equal(halfAmount.toString());
    });
  });
  
  describe("授权和代理转账", function() {
    it("应支持授权和代理转账流程", async function() {
      // 从owner转移100个代币到addr1
      const amount = ethers.utils.parseUnits("100", tokenDecimals);
      await token.transfer(addr1.address, amount);
      
      // addr1授权addr2可以使用50个代币
      const approveAmount = amount.div(2);
      await token.connect(addr1).approve(addr2.address, approveAmount);
      
      // 检查授权额度
      const allowance = await token.allowance(addr1.address, addr2.address);
      expect(allowance.toString()).to.equal(approveAmount.toString());
      
      // addr2代表addr1转账25个代币给owner
      const transferAmount = approveAmount.div(2);
      await token.connect(addr2).transferFrom(addr1.address, owner.address, transferAmount);
      
      // 检查余额
      const addr1Balance = await token.balanceOf(addr1.address);
      expect(addr1Balance.toString()).to.equal(amount.sub(transferAmount).toString());
      
      // 检查剩余授权额度
      const remainingAllowance = await token.allowance(addr1.address, addr2.address);
      expect(remainingAllowance.toString()).to.equal(approveAmount.sub(transferAmount).toString());
    });
  });
}); 