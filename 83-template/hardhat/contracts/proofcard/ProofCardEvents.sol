// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ProofCardEvents
 * @dev 定义所有ProofCard相关的事件
 */
contract ProofCardEvents {
    // 单个转账事件
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    
    // 批量转账事件
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    
    // 授权事件
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    
    // URI更新事件
    event URI(string value, uint256 indexed id);
    
    // 初始化事件
    event Initialized(string name, string baseUri);
} 