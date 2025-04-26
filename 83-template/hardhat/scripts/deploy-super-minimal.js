const hre = require("hardhat");

async function main() {
  console.log("开始部署超简单合约...");
  console.log("网络名称:", hre.network.name);
  const [deployer] = await hre.ethers.getSigners();
  console.log("部署账户:", deployer.address);
  console.log("账户余额:", hre.ethers.utils.formatEther(await deployer.getBalance()));

  try {
    console.log("正在编译合约...");
    await hre.run("compile");
    
    console.log("正在创建 SuperMinimal 合约工厂...");
    const SuperMinimal = await hre.ethers.getContractFactory("SuperMinimal");
    
    console.log("正在部署 SuperMinimal 合约...");
    const superMinimal = await SuperMinimal.deploy();
    
    console.log("等待交易确认...");
    console.log("交易哈希:", superMinimal.deployTransaction.hash);
    await superMinimal.deployed();
    
    console.log(`SuperMinimal 合约已部署到: ${superMinimal.address}`);
    console.log("部署成功！");
    
  } catch (error) {
    console.error("部署过程中发生错误:");
    console.error(error);
    
    // 更详细的错误信息
    if (error.code) console.error("错误代码:", error.code);
    if (error.reason) console.error("错误原因:", error.reason);
    if (error.error) console.error("内部错误:", error.error);
    if (error.transaction) {
      console.error("交易哈希:", error.transaction.hash);
      console.error("发送者:", error.transaction.from);
      console.error("接收者:", error.transaction.to);
      console.error("数据:", error.transaction.data?.substring(0, 100) + "...");
    }
    if (error.message) console.error("错误消息:", error.message);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 