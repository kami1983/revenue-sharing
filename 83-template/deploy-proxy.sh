#!/bin/bash

# 定义颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

echo -e "${YELLOW}开始部署ProofCard代理版本...${NC}"

# 进入hardhat目录
cd hardhat

# 安装依赖（如果需要）
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}安装依赖...${NC}"
    npm install
fi

# 运行部署脚本
echo -e "${YELLOW}执行部署脚本...${NC}"
npx hardhat run scripts/deploy-proof-card-proxy.js --network localhost

echo -e "${GREEN}部署过程完成!${NC}" 