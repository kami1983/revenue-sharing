#!/bin/bash

# 显示测试开始
echo "开始运行RedPacket测试..."

# 进入hardhat目录
cd hardhat

# 只运行RedPacket测试
npx hardhat test test/RedPacket.test.js

# 显示测试结果
if [ $? -eq 0 ]; then
  echo "RedPacket测试成功完成！"
else
  echo "RedPacket测试失败！"
  exit 1
fi 