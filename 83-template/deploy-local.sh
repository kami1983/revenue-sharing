#!/bin/bash

echo "========== 开始本地部署流程 =========="

# 进入hardhat目录
cd hardhat

# 编译合约
echo "编译智能合约..."
npx hardhat compile

# 部署轻量级ERC20代币
echo "部署轻量级ERC20代币..."
npx hardhat run scripts/deploy-lightweight-erc20.js --network localhost

echo "========== 部署流程完成 ==========" 