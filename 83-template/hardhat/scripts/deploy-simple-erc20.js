const hre = require("hardhat");

async function main() {
  const tokenName = "Simple Token";
  const tokenSymbol = "ST";
  const tokenDecimals = 18;
  const initialSupply = 1000000; // 1,000,000 tokens
  
  console.log("开始部署SimpleERC20代币...");
  console.log(`名称: ${tokenName}`);
  console.log(`符号: ${tokenSymbol}`);
  console.log(`小数位: ${tokenDecimals}`);
  console.log(`初始供应量: ${initialSupply} (${initialSupply * 10**tokenDecimals} wei)`);
  
  const SimpleERC20 = await hre.ethers.getContractFactory("SimpleERC20");
  const token = await SimpleERC20.deploy(tokenName, tokenSymbol, tokenDecimals, initialSupply);
  
  await token.deployed();
  
  console.log(`SimpleERC20代币已部署到地址: ${token.address}`);
  
  const deployer = (await hre.ethers.getSigners())[0];
  const deployerBalance = await token.balanceOf(deployer.address);
  console.log(`部署者地址: ${deployer.address}`);
  console.log(`部署者代币余额: ${deployerBalance.toString()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 