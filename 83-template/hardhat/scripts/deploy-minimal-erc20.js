const hre = require("hardhat");

async function main() {
  console.log("开始部署SimpleMinimalErc20合约...");
  
  // 获取合约工厂
  const SimpleMinimalErc20 = await hre.ethers.getContractFactory("SimpleMinimalErc20");
  
  // 部署参数
  const name = "Minimal Token";
  const symbol = "MIN";
  const decimals = 18;
  const initialSupply = hre.ethers.utils.parseUnits("1000000", decimals); // 1,000,000 代币
  
  console.log("部署参数:");
  console.log(`- 名称: ${name}`);
  console.log(`- 符号: ${symbol}`);
  console.log(`- 小数位: ${decimals}`);
  console.log(`- 初始总量: ${hre.ethers.utils.formatUnits(initialSupply, decimals)} (${initialSupply.toString()})`);
  
  console.log("部署合约中...");
  
  // 部署合约
  const minimalToken = await SimpleMinimalErc20.deploy(
    name,
    symbol,
    decimals,
    initialSupply
  );
  
  console.log("等待交易确认...");
  await minimalToken.deployed();
  
  console.log("合约已部署到:", minimalToken.address);
  console.log("部署成功！");
  
  // 获取部署者地址
  const deployer = await minimalToken.signer.getAddress();
  console.log("部署者地址:", deployer);
  
  // 检查部署者代币余额
  const balance = await minimalToken.balanceOf(deployer);
  console.log(`部署者余额: ${hre.ethers.utils.formatUnits(balance, decimals)} ${symbol}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署过程中发生错误:");
    console.error(error);
    process.exit(1);
  }); 