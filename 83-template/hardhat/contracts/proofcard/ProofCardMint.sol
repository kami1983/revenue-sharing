// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProofCardTransfer.sol";

/**
 * @title ProofCardMint
 * @dev 处理铸造相关功能
 */
contract ProofCardMint is ProofCardTransfer {
    /**
     * @dev 构造函数
     */
    constructor(string memory tokenName, string memory baseURI) ProofCardTransfer(tokenName, baseURI) {}
    
    /**
     * @dev 铸造新的NFT
     * @param to 接收者地址
     * @param amount 铸造数量
     * @param data 附加数据
     * @return 新铸造的代币ID
     */
    function mint(address to, uint256 amount, bytes memory data) public returns (uint256) {
        require(to != address(0), "ProofCard: mint to zero address");
        
        uint256 tokenId = _nextTokenId;
        _nextTokenId += 1;
        
        _mint(to, tokenId, amount, data);
        _creators[tokenId] = msg.sender;
        
        return tokenId;
    }
    
    /**
     * @dev 使用现有ID铸造更多NFT
     * @param to 接收者地址
     * @param id 代币ID
     * @param amount 铸造数量
     * @param data 附加数据
     */
    function mintMore(address to, uint256 id, uint256 amount, bytes memory data) public {
        require(to != address(0), "ProofCard: mint to zero address");
        require(_exists(id), "ProofCard: token ID does not exist");
        require(_isCreator(id, msg.sender), "ProofCard: not token creator");
        
        _mint(to, id, amount, data);
    }
    
    /**
     * @dev 内部铸造实现
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal {
        _balances[id][to] += amount;
        
        emit TransferSingle(msg.sender, address(0), to, id, amount);
        
        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, amount, data);
    }
    
    /**
     * @dev 重写父合约中的安全检查函数，避免重复定义
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal override {
        super._doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }
} 