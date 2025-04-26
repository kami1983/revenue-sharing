// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  console.log("开始部署合约...");

  // 部署 RevenueVault 合约
  const RevenueVault = await hre.ethers.getContractFactory("RevenueVault");
  const revenueVault = await RevenueVault.deploy();
  await revenueVault.waitForDeployment();
  console.log(`RevenueVault 合约已部署到: ${await revenueVault.getAddress()}`);

  // 部署 MockUSDC 合约
  const MockUSDC = await hre.ethers.getContractFactory("MockUSDC");
  const mockUSDC = await MockUSDC.deploy();
  await mockUSDC.waitForDeployment();
  console.log(`MockUSDC 合约已部署到: ${await mockUSDC.getAddress()}`);

  // 添加 USDC 到支持的代币列表
  await revenueVault.addSupportedToken(await mockUSDC.getAddress());
  console.log("MockUSDC 已添加到 RevenueVault 的支持代币列表");

  console.log("部署完成！");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
