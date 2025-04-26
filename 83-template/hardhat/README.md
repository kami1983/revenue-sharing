# Revenue Sharing Vault

智能合约库，实现了收益分享系统，通过 Vault NFT 进行分配。

## 项目描述

通过 Vault 合约和由这些合约铸造的 Vault NFT 运作。发送到 Vault 的资金在个人索赔之前平均分配给所有 Vault NFT 的所有者。任何 Vault NFT 所有者都可以随时触发分配。第一个触发者为其他参与者支付 Gas。

例如，假设 Vault 收到了 200 美元 USDC，还假设您持有 1000 个 NFT 中的 10 个 Vault NFT，因此您将能够收到：200*(10/1000) = 2 美元 USDC。

## 合约结构

- `RevenueVault.sol`：主要的收益分享 Vault 合约，实现 NFT 铸造和收益分配
- `MockUSDC.sol`：用于测试的模拟 USDC 代币

## 安装和设置

1. 安装依赖：
```bash
npm install
```

2. 编译合约：
```bash
npx hardhat compile
```

3. 运行测试：
```bash
npx hardhat test
```

4. 启动本地节点：
```bash
npx hardhat node
```

5. 部署合约到本地网络：
```bash
npx hardhat run scripts/deploy.js --network localhost
```

## 测试

本项目包含全面的测试套件，涵盖了：
- 合约部署
- NFT 铸造
- ETH 收益分配
- USDC 收益分配
- 奖励查询和领取

运行测试：
```bash
npx hardhat test
```

## 技术栈

- Solidity ^0.8.18
- Hardhat
- OpenZeppelin 合约库
- Ethers.js

## 许可证

MIT
