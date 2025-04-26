// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProofCardBase.sol";

/**
 * @title ProofCardMetadata
 * @dev 处理URI和元数据相关功能
 */
contract ProofCardMetadata is ProofCardBase {
    // 基础URI
    string private _uri;
    
    // NFT元数据
    mapping(uint256 => string) private _tokenURIs;
    
    // NFT创建者
    mapping(uint256 => address) internal _creators;
    
    /**
     * @dev 构造函数
     * @param tokenName 合约名称
     * @param baseURI 基础URI
     */
    constructor(string memory tokenName, string memory baseURI) ProofCardBase(tokenName) {
        _uri = baseURI;
    }
    
    /**
     * @dev 获取代币URI
     * @param id 代币ID
     */
    function uri(uint256 id) public view returns (string memory) {
        string memory tokenURI = _tokenURIs[id];
        
        // 如果有特定的tokenURI，则返回它
        if (bytes(tokenURI).length > 0) {
            return tokenURI;
        }
        
        // 否则返回基础URI
        return _uri;
    }
    
    /**
     * @dev 设置特定代币的URI
     * @param id 代币ID
     * @param tokenURI 代币URI
     */
    function setTokenURI(uint256 id, string memory tokenURI) public {
        require(_exists(id), "ProofCard: URI set for nonexistent token");
        require(_isCreator(id, msg.sender), "ProofCard: caller is not creator");
        
        _tokenURIs[id] = tokenURI;
        emit URI(tokenURI, id);
    }
    
    /**
     * @dev 设置基础URI
     * @param newBaseURI 新的基础URI
     */
    function setBaseURI(string memory newBaseURI) public {
        _uri = newBaseURI;
    }
    
    /**
     * @dev 检查代币ID是否存在
     */
    function _exists(uint256 id) internal view returns (bool) {
        return _creators[id] != address(0);
    }
    
    /**
     * @dev 检查是否为代币创建者
     */
    function _isCreator(uint256 id, address account) internal view returns (bool) {
        return _creators[id] == account;
    }
} 