const hre = require("hardhat");

async function main() {
  console.log("开始部署简化版ERC1155合约...");
  
  // 获取合约工厂
  const SimpleTest1155NFT = await hre.ethers.getContractFactory("SimpleTest1155NFT");
  
  console.log("部署合约中...");
  // 部署合约，传入URI参数
  const simpleTest1155 = await SimpleTest1155NFT.deploy("https://game.example/api/item/{id}.json");
  
  console.log("等待交易确认...");
  await simpleTest1155.deployed();
  
  console.log("合约已部署到:", simpleTest1155.address);
  console.log("部署成功！");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署过程中发生错误:");
    console.error(error);
    process.exit(1);
  }); 