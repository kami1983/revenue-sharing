const hre = require("hardhat");

async function main() {
  // 创建随机钱包
  const wallet = hre.ethers.Wallet.createRandom();
  
  console.log("地址:", wallet.address);
  console.log("私钥:", wallet.privateKey);
  console.log("助记词:", wallet.mnemonic.phrase);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 