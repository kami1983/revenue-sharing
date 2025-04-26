// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/IERC1155Receiver.sol";
import "./ProofCardMetadata.sol";

/**
 * @title ProofCardTransfer
 * @dev 处理转账相关功能
 */
contract ProofCardTransfer is ProofCardMetadata {
    /**
     * @dev 构造函数
     */
    constructor(string memory tokenName, string memory baseURI) ProofCardMetadata(tokenName, baseURI) {}
    
    /**
     * @dev 单个NFT转账
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCard: not owner nor approved"
        );
        require(to != address(0), "ProofCard: transfer to zero address");
        
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ProofCard: insufficient balance");
        
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;
        
        emit TransferSingle(msg.sender, from, to, id, amount);
        
        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }
    
    /**
     * @dev 批量NFT转账
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCard: not owner nor approved"
        );
        require(to != address(0), "ProofCard: transfer to zero address");
        require(ids.length == amounts.length, "ProofCard: ids/amounts mismatch");
        
        for(uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            
            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ProofCard: insufficient balance");
            
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }
        
        emit TransferBatch(msg.sender, from, to, ids, amounts);
        
        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }
    
    /**
     * @dev 单个交易安全检查
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ProofCard: ERC1155Receiver rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCard: transfer to non-receiver");
            }
        }
    }
    
    /**
     * @dev 批量交易安全检查
     */
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ProofCard: ERC1155Receiver rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCard: transfer to non-receiver");
            }
        }
    }
} 