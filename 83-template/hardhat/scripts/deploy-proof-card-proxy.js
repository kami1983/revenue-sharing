const hre = require("hardhat");

async function main() {
  console.log("开始部署ProofCard代理版本...");
  
  // 1. 首先部署实现合约
  console.log("部署实现合约...");
  const ProofCardImplementation = await hre.ethers.getContractFactory("ProofCardImplementation");
  const implementation = await ProofCardImplementation.deploy();
  await implementation.deployed();
  console.log(`实现合约已部署到: ${implementation.address}`);
  
  // 2. 部署代理合约
  console.log("部署代理合约...");
  const ProofCard = await hre.ethers.getContractFactory("ProofCard");
  const proofCard = await ProofCard.deploy(implementation.address);
  await proofCard.deployed();
  
  console.log(`代理合约已部署到: ${proofCard.address}`);
  
  // 3. 为代理合约提供ABI (使用实现合约的ABI)
  const proofCardWithImplementationABI = await hre.ethers.getContractAt(
    "ProofCardImplementation", 
    proofCard.address
  );
  
  // 4. 初始化代理合约
  console.log("初始化代理合约...");
  const name = "Proof Card";
  const baseURI = "https://ipfs.io/ipfs/";
  
  const tx = await proofCardWithImplementationABI.initialize(name, baseURI);
  await tx.wait();
  
  console.log("初始化完成，检查合约状态...");
  const contractName = await proofCardWithImplementationABI.name();
  console.log(`合约名称: ${contractName}`);
  
  // 5. 铸造一个NFT作为测试
  console.log("铸造测试NFT...");
  const signer = await proofCardWithImplementationABI.signer.getAddress();
  const mintTx = await proofCardWithImplementationABI.mint(signer, 1, "0x");
  const receipt = await mintTx.wait();
  
  // 解析事件获取tokenId
  const event = receipt.events.find(e => e.event === 'TransferSingle');
  const tokenId = event.args.id;
  
  console.log(`铸造完成，代币ID: ${tokenId}`);
  const balance = await proofCardWithImplementationABI.balanceOf(signer, tokenId);
  console.log(`用户余额: ${balance}`);
  
  console.log("部署和初始化全部完成！");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署过程中发生错误:");
    console.error(error);
    process.exit(1);
  }); 