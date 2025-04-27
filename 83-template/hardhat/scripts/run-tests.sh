#!/bin/bash

# 显示测试开始
echo "开始运行SimpleERC20测试..."

# 运行测试
cd hardhat
npx hardhat test

# 显示测试结果
if [ $? -eq 0 ]; then
  echo "测试成功完成！"
else
  echo "测试失败！"
  exit 1
fi 