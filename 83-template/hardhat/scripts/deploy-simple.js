const hre = require("hardhat");

async function main() {
  console.log("开始部署简单测试合约...");
  console.log("网络名称:", hre.network.name);
  const [deployer] = await hre.ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", hre.ethers.utils.formatEther(await deployer.getBalance()));

  try {
    console.log("正在编译合约...");
    await hre.run("compile");
    
    console.log("正在创建 SimpleTest 合约工厂...");
    const SimpleTest = await hre.ethers.getContractFactory("SimpleTest");
    
    // 使用网络默认配置，不额外指定gas
    console.log("正在部署 SimpleTest 合约...");
    const simpleTest = await SimpleTest.deploy();
    
    console.log("等待交易确认...");
    console.log("交易哈希:", simpleTest.deployTransaction.hash);
    await simpleTest.deployed();
    
    console.log(`SimpleTest 合约已部署到: ${simpleTest.address}`);
    console.log("部署成功！");
    
  } catch (error) {
    console.error("部署过程中发生错误:");
    console.error(error);
    
    // 更详细的错误信息
    if (error.code) console.error("错误代码:", error.code);
    if (error.reason) console.error("错误原因:", error.reason);
    if (error.error) console.error("内部错误:", error.error);
    if (error.transaction) console.error("交易详情:", error.transaction);
    if (error.message) console.error("错误消息:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 