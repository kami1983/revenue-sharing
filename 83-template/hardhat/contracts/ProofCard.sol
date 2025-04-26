// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./proofcard/ProofCardMint.sol";

/**
 * @title ProofCard
 * @dev ERC-1155 NFT实现，以模块化方式组织
 */
contract ProofCard is ProofCardMint {
    /**
     * @dev 构造函数
     * @param tokenName 合约名称
     * @param baseURI 基础URI
     */
    constructor(string memory tokenName, string memory baseURI) ProofCardMint(tokenName, baseURI) {}
} 