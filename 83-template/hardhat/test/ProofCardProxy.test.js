const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProofCardProxy", function () {
  let implementation;
  let proofCard;
  let proofCardWithImplementationABI;
  let owner;
  let user1;
  let user2;
  let tokenId;

  beforeEach(async function () {
    // 获取测试账户
    [owner, user1, user2] = await ethers.getSigners();

    // 部署实现合约
    const ProofCardImplementation = await ethers.getContractFactory("ProofCardImplementation");
    implementation = await ProofCardImplementation.deploy();
    await implementation.deployed();

    // 部署代理合约
    const ProofCard = await ethers.getContractFactory("ProofCard");
    proofCard = await ProofCard.deploy(implementation.address);
    await proofCard.deployed();

    // 为代理合约提供ABI (使用实现合约的ABI)
    proofCardWithImplementationABI = await ethers.getContractAt(
      "ProofCardImplementation", 
      proofCard.address
    );

    // 初始化代理合约
    await proofCardWithImplementationABI.initialize("Proof Card", "https://ipfs.io/ipfs/");
    
    // 铸造一个新的NFT
    const mintTx = await proofCardWithImplementationABI.mint(user1.address, 10, "0x");
    const receipt = await mintTx.wait();
    
    // 解析事件获取tokenId
    const event = receipt.events.find(e => e.event === 'TransferSingle');
    tokenId = event.args.id;
  });

  it("应该正确铸造NFT并分配给用户", async function () {
    // 检查用户余额
    const balance = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId);
    expect(balance).to.equal(10);
  });

  it("应该允许创建者为同一ID铸造更多代币", async function () {
    // 再铸造10个相同ID的NFT
    await proofCardWithImplementationABI.mintMore(user1.address, tokenId, 15, "0x");
    
    // 检查更新后的余额
    const balance = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId);
    expect(balance).to.equal(25);
  });

  it("应该允许转移NFT", async function () {
    // user1转移5个代币给user2
    await proofCardWithImplementationABI.connect(user1).safeTransferFrom(
      user1.address, 
      user2.address, 
      tokenId, 
      5, 
      "0x"
    );
    
    // 检查两个用户的余额
    const user1Balance = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId);
    const user2Balance = await proofCardWithImplementationABI.balanceOf(user2.address, tokenId);
    
    expect(user1Balance).to.equal(5);
    expect(user2Balance).to.equal(5);
  });

  it("应该允许批准其他用户操作NFT", async function () {
    // user1授权user2操作所有NFT
    await proofCardWithImplementationABI.connect(user1).setApprovalForAll(user2.address, true);
    
    // 检查授权状态
    const isApproved = await proofCardWithImplementationABI.isApprovedForAll(user1.address, user2.address);
    expect(isApproved).to.be.true;
    
    // user2代表user1转移NFT
    await proofCardWithImplementationABI.connect(user2).safeTransferFrom(
      user1.address, 
      user2.address, 
      tokenId, 
      3, 
      "0x"
    );
    
    // 检查两个用户的余额
    const user1Balance = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId);
    const user2Balance = await proofCardWithImplementationABI.balanceOf(user2.address, tokenId);
    
    expect(user1Balance).to.equal(7);
    expect(user2Balance).to.equal(3);
  });

  it("应该允许设置和查询代币URI", async function () {
    // 设置新的URI
    const tokenURI = "ipfs://QmExample";
    await proofCardWithImplementationABI.setTokenURI(tokenId, tokenURI);
    
    // 查询URI
    const retrievedURI = await proofCardWithImplementationABI.uri(tokenId);
    expect(retrievedURI).to.equal(tokenURI);
  });

  it("应该阻止非创建者为代币ID设置URI", async function () {
    // user1尝试设置URI（应该失败，因为创建者是owner）
    await expect(
      proofCardWithImplementationABI.connect(user1).setTokenURI(tokenId, "ipfs://QmFail")
    ).to.be.revertedWith("ProofCardImplementation: caller is not creator");
  });

  it("应该阻止非创建者为代币ID铸造更多代币", async function () {
    // user2尝试为同一ID铸造更多代币（应该失败）
    await expect(
      proofCardWithImplementationABI.connect(user2).mintMore(user2.address, tokenId, 5, "0x")
    ).to.be.revertedWith("ProofCardImplementation: not token creator");
  });

  it("应该阻止余额不足的转账", async function () {
    // user1尝试转移超过其余额的代币
    await expect(
      proofCardWithImplementationABI.connect(user1).safeTransferFrom(
        user1.address, 
        user2.address, 
        tokenId, 
        20, // 余额只有10
        "0x"
      )
    ).to.be.revertedWith("ProofCardImplementation: insufficient balance");
  });

  it("应该支持批量转账", async function () {
    // 先铸造另一个新的NFT
    const mintTx = await proofCardWithImplementationABI.mint(user1.address, 5, "0x");
    const receipt = await mintTx.wait();
    const event = receipt.events.find(e => e.event === 'TransferSingle');
    const tokenId2 = event.args.id;
    
    // 批量转账
    await proofCardWithImplementationABI.connect(user1).safeBatchTransferFrom(
      user1.address,
      user2.address,
      [tokenId, tokenId2],
      [3, 2],
      "0x"
    );
    
    // 检查两个代币的余额
    const user1Balance1 = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId);
    const user2Balance1 = await proofCardWithImplementationABI.balanceOf(user2.address, tokenId);
    const user1Balance2 = await proofCardWithImplementationABI.balanceOf(user1.address, tokenId2);
    const user2Balance2 = await proofCardWithImplementationABI.balanceOf(user2.address, tokenId2);
    
    expect(user1Balance1).to.equal(7);
    expect(user2Balance1).to.equal(3);
    expect(user1Balance2).to.equal(3);
    expect(user2Balance2).to.equal(2);
  });
  
  it("应该能够通过代理访问实现合约地址", async function () {
    const implAddress = await proofCard.implementation();
    expect(implAddress).to.equal(implementation.address);
  });
  
  it("应该能够通过代理访问管理员地址", async function () {
    const adminAddress = await proofCard.admin();
    expect(adminAddress).to.equal(owner.address);
  });
  
  it("应该能够升级实现合约", async function () {
    // 部署新的实现合约
    const NewImplementation = await ethers.getContractFactory("ProofCardImplementation");
    const newImplementation = await NewImplementation.deploy();
    await newImplementation.deployed();
    
    // 升级代理合约
    await proofCard.upgradeTo(newImplementation.address);
    
    // 检查实现合约地址是否已更改
    const implAddress = await proofCard.implementation();
    expect(implAddress).to.equal(newImplementation.address);
  });
  
  it("应该只允许管理员升级实现合约", async function () {
    // 部署新的实现合约
    const NewImplementation = await ethers.getContractFactory("ProofCardImplementation");
    const newImplementation = await NewImplementation.deploy();
    await newImplementation.deployed();
    
    // 非管理员尝试升级代理合约（应该失败）
    await expect(
      proofCard.connect(user1).upgradeTo(newImplementation.address)
    ).to.be.revertedWith("ProofCardProxy: caller is not admin");
  });
}); 