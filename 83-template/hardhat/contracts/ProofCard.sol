// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./proofcard/ProofCardProxy.sol";

/**
 * @title ProofCard
 * @dev ERC-1155 NFT实现，使用代理模式组织，将调用委托给实现合约
 */
contract ProofCard is ProofCardProxy {
    /**
     * @dev 构造函数
     * @param implementation_ 实现合约地址
     */
    constructor(address implementation_) ProofCardProxy(implementation_) {
        // 代理构造函数已经设置好了实现合约
    }
} 