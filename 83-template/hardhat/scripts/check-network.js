const hre = require("hardhat");

async function main() {
  try {
    console.log("-------- 网络兼容性检查 --------");
    console.log("网络名称:", hre.network.name);
    
    // 获取网络基本信息
    const [signer] = await hre.ethers.getSigners();
    console.log("账户地址:", await signer.getAddress());
    console.log("账户余额:", hre.ethers.utils.formatEther(await signer.getBalance()), "ETH");
    
    // 获取链ID
    const chainId = await hre.ethers.provider.getNetwork().then(n => n.chainId);
    console.log("链ID:", chainId.toString());
    
    // 获取最新区块
    const latestBlock = await hre.ethers.provider.getBlock("latest");
    console.log("最新区块号:", latestBlock.number);
    console.log("最新区块哈希:", latestBlock.hash);
    
    // 获取gasPrice
    const gasPrice = await hre.ethers.provider.getGasPrice();
    console.log("当前Gas价格:", hre.ethers.utils.formatUnits(gasPrice, "gwei"), "gwei");
    
    // 尝试估算一个简单交易的gas
    try {
      const gasEstimate = await hre.ethers.provider.estimateGas({
        to: "0x0000000000000000000000000000000000000000",
        value: hre.ethers.utils.parseEther("0.0001")
      });
      console.log("简单交易的Gas估算:", gasEstimate.toString());
    } catch (error) {
      console.log("无法估算简单交易的Gas:", error.message);
    }
    
    console.log("网络检查完成，可以连接并获取基本信息。");
    
  } catch (error) {
    console.error("检查网络时出错:");
    console.error(error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 