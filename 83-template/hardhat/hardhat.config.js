require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    ]
  },
  ethers: {
    version: "5.7.2",
  },
  networks: {
    hardhat: {
      chainId: 31337
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337,
      gas: 3000000,
      gasPrice: 20000000000 // 20 gwei
    },
    'truffle-dashboard': {
      url: "http://localhost:24012/rpc",
      timeout: 60000,
      gasLimit: 3000000,
      gasPrice: "auto"
    },
    'asset-hub-westend': {
      url: "https://westend-asset-hub-eth-rpc.polkadot.io",
      chainId: 420420421,
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};
