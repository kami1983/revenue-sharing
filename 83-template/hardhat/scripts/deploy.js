// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  console.log("开始部署合约...");
  console.log("网络名称:", hre.network.name);
  console.log("部署账户:", (await hre.ethers.getSigners())[0].address);

  try {
    // 部署 RevenueVault 合约
    console.log("正在创建 RevenueVault 合约工厂...");
    const RevenueVault = await hre.ethers.getContractFactory("RevenueVault");
    
    // 为Asset-Hub Westend网络调整部署参数
    const deployOptions = {};
    if (hre.network.name === 'asset-hub-westend') {
      deployOptions.gasLimit = 5000000;
      deployOptions.gasPrice = hre.ethers.utils.parseUnits("1", "gwei");
    }
    
    console.log("正在部署 RevenueVault 合约...");
    console.log("部署选项:", JSON.stringify(deployOptions));
    const revenueVault = await RevenueVault.deploy(deployOptions);
    
    console.log("等待交易确认...");
    console.log("交易哈希:", revenueVault.deployTransaction.hash);
    await revenueVault.deployed();
    
    let revenueVaultAddress;
    if (typeof revenueVault.address === 'string') {
      // ethers v5
      revenueVaultAddress = revenueVault.address;
    } else {
      // ethers v6
      revenueVaultAddress = await revenueVault.getAddress();
    }
    console.log(`RevenueVault 合约已部署到: ${revenueVaultAddress}`);
  
    // 部署 MockUSDC 合约
    console.log("正在创建 MockUSDC 合约工厂...");
    const MockUSDC = await hre.ethers.getContractFactory("MockUSDC");
    
    console.log("正在部署 MockUSDC 合约...");
    const mockUSDC = await MockUSDC.deploy(deployOptions);
    
    console.log("等待交易确认...");
    console.log("交易哈希:", mockUSDC.deployTransaction.hash);
    await mockUSDC.deployed();
    
    let mockUSDCAddress;
    if (typeof mockUSDC.address === 'string') {
      // ethers v5
      mockUSDCAddress = mockUSDC.address;
    } else {
      // ethers v6
      mockUSDCAddress = await mockUSDC.getAddress();
    }
    console.log(`MockUSDC 合约已部署到: ${mockUSDCAddress}`);
  
    // 添加 USDC 到支持的代币列表
    console.log("添加 MockUSDC 到支持的代币列表...");
    const addTxOptions = { ...deployOptions };
    const addTx = await revenueVault.addSupportedToken(mockUSDCAddress, addTxOptions);
    
    console.log("等待交易确认...");
    console.log("交易哈希:", addTx.hash);
    await addTx.wait();
    console.log("MockUSDC 已添加到 RevenueVault 的支持代币列表");
  
    console.log("部署完成！");
  } catch (error) {
    console.error("部署过程中发生错误:");
    console.error(error);
    
    // 打印更多细节
    if (error.code) console.error("错误代码:", error.code);
    if (error.reason) console.error("错误原因:", error.reason);
    if (error.error) console.error("内部错误:", error.error);
    if (error.transaction) console.error("交易详情:", error.transaction);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
