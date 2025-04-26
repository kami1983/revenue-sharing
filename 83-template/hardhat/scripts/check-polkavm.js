const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

async function main() {
  console.log("===== 检查PolkaVM环境和工具 =====");
  
  console.log("\n检查是否安装了polkadot工具...");
  try {
    const output = execSync('which polkavm-cli 2>/dev/null || echo "未安装"').toString().trim();
    if (output === "未安装") {
      console.log("polkavm-cli 未安装，您可能需要安装它来使用PolkaVM功能");
      console.log("安装指南: https://github.com/paritytech/polkavm");
    } else {
      console.log(`找到 polkavm-cli: ${output}`);
      
      // 尝试运行一下版本命令
      try {
        const versionOutput = execSync('polkavm-cli --version').toString().trim();
        console.log(`polkavm-cli 版本: ${versionOutput}`);
      } catch (error) {
        console.log("无法获取polkavm-cli版本信息");
      }
    }
  } catch (error) {
    console.log("检查polkavm-cli时出错:", error.message);
  }
  
  console.log("\n关于PolkaVM部署的建议：");
  console.log("1. 使用官方专用Remix环境 (https://contracts.polkadot.io/remix)");
  console.log("2. 将Asset-Hub Westend测试网添加到MetaMask，信息如下：");
  console.log("   - 网络名称: Asset-Hub Westend Testnet");
  console.log("   - RPC URL: https://westend-asset-hub-eth-rpc.polkadot.io");
  console.log("   - 链ID: 420420421");
  console.log("   - 货币符号: WND");
  console.log("   - 区块浏览器: https://blockscout-asset-hub.parity-chains-scw.parity.io");
  console.log("3. 从测试网水龙头获取WND代币");
  console.log("4. 使用Solidity编写合约，PolkaVM支持Solidity并使用RISC-V架构");
  
  console.log("\n更多信息请访问: https://contracts.polkadot.io/docs");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 