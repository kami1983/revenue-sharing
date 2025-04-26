// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ProofCardProxy
 * @dev 一个简单的代理合约，将所有调用委托给实现合约
 */
contract ProofCardProxy {
    // 实现合约地址
    address private _implementation;
    
    // 管理员地址
    address private _admin;
    
    // 存储初始化状态
    bool private _initialized;
    
    // 事件
    event Upgraded(address indexed implementation);
    
    /**
     * @dev 构造函数
     * @param implementation_ 逻辑合约地址
     */
    constructor(address implementation_) {
        _admin = msg.sender;
        _implementation = implementation_;
        emit Upgraded(implementation_);
    }
    
    /**
     * @dev 修改器：只有管理员可以调用
     */
    modifier onlyAdmin() {
        require(msg.sender == _admin, "ProofCardProxy: caller is not admin");
        _;
    }
    
    /**
     * @dev 升级实现合约
     * @param newImplementation 新的实现合约地址
     */
    function upgradeTo(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "ProofCardProxy: implementation is zero address");
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }
    
    /**
     * @dev 获取当前实现合约地址
     */
    function implementation() external view returns (address) {
        return _implementation;
    }
    
    /**
     * @dev 获取管理员地址
     */
    function admin() external view returns (address) {
        return _admin;
    }
    
    /**
     * @dev 回退函数，将所有调用委托给实现合约
     */
    fallback() external payable {
        _delegate(_implementation);
    }
    
    /**
     * @dev 接收以太币函数
     */
    receive() external payable {
        _delegate(_implementation);
    }
    
    /**
     * @dev 委托调用到实现合约
     */
    function _delegate(address implementation_) internal {
        assembly {
            // 复制调用数据
            calldatacopy(0, 0, calldatasize())
            
            // 执行委托调用
            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)
            
            // 获取返回数据大小
            let size := returndatasize()
            
            // 复制返回数据
            returndatacopy(0, 0, size)
            
            switch result
            case 0 {
                // 委托调用失败，恢复之前的状态
                revert(0, size)
            }
            default {
                // 委托调用成功，返回数据
                return(0, size)
            }
        }
    }
} 