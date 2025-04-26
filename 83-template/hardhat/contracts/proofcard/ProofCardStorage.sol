// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ProofCardStorage
 * @dev 存储合约，包含所有ProofCard相关的数据结构和状态变量
 */
contract ProofCardStorage {
    // 代理合约的存储结构，用于避免存储冲突
    bytes32 constant PROXY_STORAGE_SLOT = keccak256("proofcard.proxy.storage");
    
    struct ProxyStorage {
        address implementation;
        address admin;
        bool initialized;
    }
    
    // ProofCard存储结构
    bytes32 constant PROOFCARD_STORAGE_SLOT = keccak256("proofcard.storage");
    
    struct ProofCardData {
        // 合约名称
        string name;
        
        // 基础URI
        string baseUri;
        
        // 映射：tokenId => (账户 => 余额)
        mapping(uint256 => mapping(address => uint256)) balances;
        
        // 映射：账户 => (操作者 => 是否批准)
        mapping(address => mapping(address => bool)) operatorApprovals;
        
        // NFT元数据
        mapping(uint256 => string) tokenURIs;
        
        // NFT创建者
        mapping(uint256 => address) creators;
        
        // 下一个可用的tokenId
        uint256 nextTokenId;
    }
    
    /**
     * @dev 获取Proxy存储
     */
    function _getProxyStorage() internal pure returns (ProxyStorage storage ps) {
        bytes32 position = PROXY_STORAGE_SLOT;
        assembly {
            ps.slot := position
        }
    }
    
    /**
     * @dev 获取ProofCard存储
     */
    function _getProofCardStorage() internal pure returns (ProofCardData storage pcs) {
        bytes32 position = PROOFCARD_STORAGE_SLOT;
        assembly {
            pcs.slot := position
        }
    }
} 