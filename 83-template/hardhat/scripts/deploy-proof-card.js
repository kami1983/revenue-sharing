const hre = require("hardhat");

async function main() {
  console.log("开始部署ProofCard合约...");
  
  // 获取合约工厂
  const ProofCard = await hre.ethers.getContractFactory("ProofCard");
  
  // 部署参数
  const name = "Proof Card";
  const baseURI = "https://ipfs.io/ipfs/";
  
  console.log("部署参数:");
  console.log(`- 名称: ${name}`);
  console.log(`- 基础URI: ${baseURI}`);
  
  console.log("部署合约中...");
  
  // 部署合约
  const proofCard = await ProofCard.deploy(
    name,
    baseURI
  );
  
  console.log("等待交易确认...");
  await proofCard.deployed();
  
  console.log("合约已部署到:", proofCard.address);
  console.log("部署成功！");
  
  // 铸造一个示例NFT
  console.log("铸造示例NFT...");
  const mintTx = await proofCard.mint(
    await proofCard.signer.getAddress(), // 接收者地址
    1, // 数量
    "0x" // 空数据
  );
  
  await mintTx.wait();
  console.log("铸造完成，代币ID:", 1);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署过程中发生错误:");
    console.error(error);
    process.exit(1);
  }); 