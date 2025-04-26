const hre = require("hardhat");

async function main() {
  console.log("开始部署SimpleTestErc20合约...");
  
  // 获取合约工厂
  const SimpleTestErc20 = await hre.ethers.getContractFactory("SimpleTestErc20");
  
  // 部署参数
  const name = "Simple Test Token";
  const symbol = "STT";
  const decimals = 18;
  const initialSupply = 1000000; // 1 million tokens
  
  console.log("部署参数:");
  console.log(`- 名称: ${name}`);
  console.log(`- 符号: ${symbol}`);
  console.log(`- 小数位: ${decimals}`);
  console.log(`- 初始供应量: ${initialSupply} (${initialSupply * (10 ** decimals)} wei)`);
  
  console.log("部署合约中...");
  
  // 部署合约
  const simpleToken = await SimpleTestErc20.deploy(
    name,
    symbol,
    decimals,
    initialSupply
  );
  
  console.log("等待交易确认...");
  await simpleToken.deployed();
  
  console.log("合约已部署到:", simpleToken.address);
  console.log("部署成功！");
  
  // 显示部署者余额
  const [deployer] = await hre.ethers.getSigners();
  const deployerBalance = await simpleToken.balanceOf(deployer.address);
  console.log(
    `部署者 (${deployer.address}) 余额:`,
    hre.ethers.utils.formatUnits(deployerBalance, decimals),
    symbol
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("部署过程中发生错误:");
    console.error(error);
    process.exit(1);
  }); 