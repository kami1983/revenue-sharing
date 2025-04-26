const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProofCard", function () {
  let proofCard;
  let owner;
  let user1;
  let user2;
  let tokenId;

  beforeEach(async function () {
    // 获取测试账户
    [owner, user1, user2] = await ethers.getSigners();

    // 部署合约
    const ProofCard = await ethers.getContractFactory("ProofCard");
    proofCard = await ProofCard.deploy("Proof Card", "https://ipfs.io/ipfs/");
    await proofCard.deployed();

    // 铸造一个新的NFT
    const mintTx = await proofCard.mint(user1.address, 10, "0x");
    const receipt = await mintTx.wait();
    
    // 解析事件获取tokenId
    const event = receipt.events.find(e => e.event === 'TransferSingle');
    tokenId = event.args.id;
  });

  it("应该正确铸造NFT并分配给用户", async function () {
    // 检查用户余额
    const balance = await proofCard.balanceOf(user1.address, tokenId);
    expect(balance).to.equal(10);
  });

  it("应该允许创建者为同一ID铸造更多代币", async function () {
    // 再铸造10个相同ID的NFT
    await proofCard.mintMore(user1.address, tokenId, 15, "0x");
    
    // 检查更新后的余额
    const balance = await proofCard.balanceOf(user1.address, tokenId);
    expect(balance).to.equal(25);
  });

  it("应该允许转移NFT", async function () {
    // user1转移5个代币给user2
    await proofCard.connect(user1).safeTransferFrom(
      user1.address, 
      user2.address, 
      tokenId, 
      5, 
      "0x"
    );
    
    // 检查两个用户的余额
    const user1Balance = await proofCard.balanceOf(user1.address, tokenId);
    const user2Balance = await proofCard.balanceOf(user2.address, tokenId);
    
    expect(user1Balance).to.equal(5);
    expect(user2Balance).to.equal(5);
  });

  it("应该允许批准其他用户操作NFT", async function () {
    // user1授权user2操作所有NFT
    await proofCard.connect(user1).setApprovalForAll(user2.address, true);
    
    // 检查授权状态
    const isApproved = await proofCard.isApprovedForAll(user1.address, user2.address);
    expect(isApproved).to.be.true;
    
    // user2代表user1转移NFT
    await proofCard.connect(user2).safeTransferFrom(
      user1.address, 
      user2.address, 
      tokenId, 
      3, 
      "0x"
    );
    
    // 检查两个用户的余额
    const user1Balance = await proofCard.balanceOf(user1.address, tokenId);
    const user2Balance = await proofCard.balanceOf(user2.address, tokenId);
    
    expect(user1Balance).to.equal(7);
    expect(user2Balance).to.equal(3);
  });

  it("应该允许设置和查询代币URI", async function () {
    // 设置新的URI
    const tokenURI = "ipfs://QmExample";
    await proofCard.setTokenURI(tokenId, tokenURI);
    
    // 查询URI
    const retrievedURI = await proofCard.uri(tokenId);
    expect(retrievedURI).to.equal(tokenURI);
  });

  it("应该阻止非创建者为代币ID设置URI", async function () {
    // user1尝试设置URI（应该失败，因为创建者是owner）
    await expect(
      proofCard.connect(user1).setTokenURI(tokenId, "ipfs://QmFail")
    ).to.be.revertedWith("ProofCard: caller is not token creator");
  });

  it("应该阻止非创建者为代币ID铸造更多代币", async function () {
    // user2尝试为同一ID铸造更多代币（应该失败）
    await expect(
      proofCard.connect(user2).mintMore(user2.address, tokenId, 5, "0x")
    ).to.be.revertedWith("ProofCard: caller is not token creator");
  });

  it("应该阻止余额不足的转账", async function () {
    // user1尝试转移超过其余额的代币
    await expect(
      proofCard.connect(user1).safeTransferFrom(
        user1.address, 
        user2.address, 
        tokenId, 
        20, // 余额只有10
        "0x"
      )
    ).to.be.revertedWith("ProofCard: insufficient balance for transfer");
  });

  it("应该支持批量转账", async function () {
    // 先铸造另一个新的NFT
    const mintTx = await proofCard.mint(user1.address, 5, "0x");
    const receipt = await mintTx.wait();
    const event = receipt.events.find(e => e.event === 'TransferSingle');
    const tokenId2 = event.args.id;
    
    // 批量转账
    await proofCard.connect(user1).safeBatchTransferFrom(
      user1.address,
      user2.address,
      [tokenId, tokenId2],
      [3, 2],
      "0x"
    );
    
    // 检查两个代币的余额
    const user1Balance1 = await proofCard.balanceOf(user1.address, tokenId);
    const user2Balance1 = await proofCard.balanceOf(user2.address, tokenId);
    const user1Balance2 = await proofCard.balanceOf(user1.address, tokenId2);
    const user2Balance2 = await proofCard.balanceOf(user2.address, tokenId2);
    
    expect(user1Balance1).to.equal(7);
    expect(user2Balance1).to.equal(3);
    expect(user1Balance2).to.equal(3);
    expect(user2Balance2).to.equal(2);
  });
}); 