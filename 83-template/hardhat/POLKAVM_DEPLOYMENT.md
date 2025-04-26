# 使用PolkaVM部署智能合约

本文档介绍如何将Solidity智能合约部署到支持PolkaVM的网络上，例如Asset-Hub Westend测试网。

## 什么是PolkaVM？

PolkaVM是Polkadot生态系统中的一种通用RISC-V虚拟机，允许在Polkadot网络上运行Solidity智能合约。与传统EVM相比，PolkaVM具有以下优势：

- 基于RISC-V架构，性能更高
- 支持多种编程语言，包括Solidity和Rust
- 安全性和隔离性更强
- 与Polkadot生态系统无缝集成

## 部署前准备

1. **安装MetaMask**：
   - 下载并安装MetaMask浏览器扩展

2. **添加Asset-Hub Westend测试网**：
   - 网络名称：`Asset-Hub Westend Testnet`
   - RPC URL：`https://westend-asset-hub-eth-rpc.polkadot.io`
   - 链ID：`420420421`
   - 货币符号：`WND`
   - 区块浏览器URL：`https://blockscout-asset-hub.parity-chains-scw.parity.io`

3. **获取测试代币**：
   - 从Westend Asset Hub水龙头获取WND测试代币

## 部署合约

### 方法1：使用PolkaVM专用Remix环境（推荐）

1. 访问[PolkaVM Remix](https://contracts.polkadot.io/remix)
2. 在Remix中创建新的Solidity文件，或者上传本地文件
3. 编译合约：点击"Solidity Compiler"选项卡，然后点击"Compile"按钮
4. 部署合约：
   - 选择"Deploy & Run"选项卡
   - 在环境下拉菜单中选择"Westend TestNet - Metamask"
   - 点击"Deploy"按钮

### 方法2：通过hardhat部署（当本地节点支持时）

> 注意：目前Asset-Hub Westend节点可能对hardhat部署有限制，此方法仅供参考。

```bash
# 编译合约
npx hardhat compile

# 部署到Asset-Hub Westend测试网
npx hardhat run scripts/deploy.js --network asset-hub-westend
```

## 与合约交互

部署完成后，您可以通过以下方式与合约交互：

1. **使用Remix**：
   - 在"Deploy & Run"选项卡中找到已部署的合约
   - 点击合约方法进行调用

2. **使用ethers.js**：
   ```javascript
   import { ethers } from 'ethers';
   
   // 连接到MetaMask提供的提供商
   const provider = new ethers.providers.Web3Provider(window.ethereum);
   await provider.send("eth_requestAccounts", []);
   const signer = provider.getSigner();
   
   // 创建合约实例
   const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
   const contract = new ethers.Contract(contractAddress, abi, signer);
   
   // 调用合约方法
   const greeting = await contract.getGreeting();
   await contract.setGreeting("Hello from ethers.js!");
   ```

## 示例合约

`PolkaVMTest.sol`是一个简单的测试合约，包含以下功能：

- 设置和获取问候语
- 存入资金
- 查询余额

您可以使用此合约作为起点，熟悉PolkaVM环境的开发流程。

## 注意事项

1. PolkaVM仍处于活跃开发中，某些功能可能有限制或更改
2. 某些高级Solidity功能可能尚未完全支持
3. Gas计费机制与传统EVM可能有所不同

## 更多资源

- [PolkaVM官方文档](https://contracts.polkadot.io/docs)
- [Asset-Hub Westend区块浏览器](https://blockscout-asset-hub.parity-chains-scw.parity.io)
- [PolkaVM GitHub仓库](https://github.com/paritytech/polkavm) 