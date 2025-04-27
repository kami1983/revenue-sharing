#!/bin/bash

# 显示测试开始
echo "开始运行SimpleERC20测试..."

# 进入hardhat目录
cd hardhat

# 只运行SimpleERC20测试
npx hardhat test test/SimpleERC20.test.js

# 显示测试结果
if [ $? -eq 0 ]; then
  echo "SimpleERC20测试成功完成！"
else
  echo "SimpleERC20测试失败！"
  exit 1
fi 