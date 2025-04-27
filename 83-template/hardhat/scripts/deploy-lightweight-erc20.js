const hre = require("hardhat");

async function main() {
  console.log("开始部署轻量级ERC20代币...");

  // 部署参数
  const name = "轻量级代币";
  const symbol = "LIGHT";
  const decimals = 18;
  const initialSupply = 1000000; // 初始供应量：1,000,000个代币

  console.log("部署参数:");
  console.log(`名称: ${name}`);
  console.log(`符号: ${symbol}`);
  console.log(`小数位: ${decimals}`);
  console.log(`初始供应量: ${initialSupply}个代币`);
  console.log(`初始供应量(wei): ${initialSupply * 10**decimals}`);

  // 获取合约工厂
  const LightweightERC20 = await hre.ethers.getContractFactory("LightweightERC20");
  
  // 部署合约
  console.log("部署合约中...");
  const token = await LightweightERC20.deploy(name, symbol, decimals, initialSupply);

  // 等待部署完成
  await token.deployed();

  // 获取部署者地址
  const [deployer] = await hre.ethers.getSigners();

  console.log("部署成功!");
  console.log(`合约地址: ${token.address}`);
  
  // 查询部署者的代币余额
  const deployerBalance = await token.balanceOf(deployer.address);
  console.log(`部署者余额: ${deployerBalance.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 