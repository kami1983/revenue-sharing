const hre = require("hardhat");

async function main() {
  try {
    const [signer] = await hre.ethers.getSigners();
    const address = await signer.getAddress();
    console.log("账户地址:", address);
    
    const balanceWei = await hre.ethers.provider.getBalance(address);
    const balanceEth = hre.ethers.utils.formatEther(balanceWei);
    
    console.log("网络:", hre.network.name);
    console.log("余额(Wei):", balanceWei.toString());
    console.log("余额(ETH):", balanceEth);
    
    // 检查是否有足够的余额部署合约
    if (balanceWei.eq(0)) {
      console.log("\n警告: 账户余额为0。您需要获取一些测试代币才能部署合约。");
      console.log("对于Asset-Hub Westend，您可以从水龙头获取测试代币。");
    } else if (balanceWei.lt(hre.ethers.utils.parseEther("0.1"))) {
      console.log("\n注意: 账户余额较低，可能不足以部署所有合约。");
    } else {
      console.log("\n余额充足，应该可以部署合约。");
    }
  } catch (error) {
    console.error("检查余额时出错:");
    console.error(error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 