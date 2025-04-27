# project name

Revenue Sharing Vault

## team members

alice 1800

bob 1801

## project description

开发一个区块链使用的红包功能，对这个合约发送ERC20代币，可以生成红包，红包可以被领取，红包领取后，红包内的ERC20代币将进入领取者的账户。

### 功能用例
* 生成红包，向红包合约 RevenueSharingVault 发送ERC20代币，和一个红包明文密钥比如（GOODLUCK），可以生成红包，合约返回一个红包的ID。
* 领取红包，红包领取时，提供红包ID，和红包明文密钥，如果匹配，则领取者可以领取红包，领取后，红包内的ERC20代币将进入领取者的账户。
* 查看红包，提供红白ID，查看红包的个数，金额，领取了多少，还剩多少。

### Testnet RPC

* Network name: Asset-Hub Westend Testnet
* RPC URL URL: https://westend-asset-hub-eth-rpc.polkadot.io
* Chain ID: 420420421
* Currency Symbol: WND
* Block Explorer URL: https://blockscout-asset-hub.parity-chains-scw.parity.io

### Deploy IDE
* https://remix.polkadot.io/

## features

1. solidity for erc20
2. UI based on react
3. unit test

## material

contract address in asset hub: link to web service: doc and slides link in
google doc: demo video link in youtube:

## future work

improve security of contract
