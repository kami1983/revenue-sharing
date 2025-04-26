// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/IERC1155Receiver.sol";
import "./ProofCardStorage.sol";
import "./ProofCardEvents.sol";

/**
 * @title ProofCardImplementation
 * @dev 包含ProofCard的所有逻辑实现
 */
contract ProofCardImplementation is ProofCardStorage, ProofCardEvents {
    /**
     * @dev 初始化函数，替代构造函数
     * @param name_ 代币名称
     * @param baseUri_ 基础URI
     */
    function initialize(string memory name_, string memory baseUri_) external {
        ProofCardData storage s = _getProofCardStorage();
        
        // 确保只能初始化一次
        require(bytes(s.name).length == 0, "ProofCardImplementation: already initialized");
        
        s.name = name_;
        s.baseUri = baseUri_;
        s.nextTokenId = 1;
        
        emit Initialized(name_, baseUri_);
    }
    
    /**
     * @dev 返回代币名称
     */
    function name() external view returns (string memory) {
        return _getProofCardStorage().name;
    }
    
    /**
     * @dev 返回账户在指定代币ID下的余额
     */
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ProofCardImplementation: balance query for zero address");
        return _getProofCardStorage().balances[id][account];
    }
    
    /**
     * @dev 批量返回账户在多个代币ID下的余额
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ProofCardImplementation: accounts/ids length mismatch");
        
        uint256[] memory batchBalances = new uint256[](accounts.length);
        
        for(uint256 i = 0; i < accounts.length; i++) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        
        return batchBalances;
    }
    
    /**
     * @dev 设置或撤销操作者对调用者所有代币的批准
     */
    function setApprovalForAll(address operator, bool approved) public {
        ProofCardData storage s = _getProofCardStorage();
        s.operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    /**
     * @dev 查询操作者是否被账户批准
     */
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _getProofCardStorage().operatorApprovals[account][operator];
    }
    
    /**
     * @dev 获取代币URI
     */
    function uri(uint256 id) public view returns (string memory) {
        ProofCardData storage s = _getProofCardStorage();
        string memory tokenURI = s.tokenURIs[id];
        
        // 如果有特定的tokenURI，则返回它
        if (bytes(tokenURI).length > 0) {
            return tokenURI;
        }
        
        // 否则返回基础URI
        return s.baseUri;
    }
    
    /**
     * @dev 设置特定代币的URI
     */
    function setTokenURI(uint256 id, string memory tokenURI) public {
        ProofCardData storage s = _getProofCardStorage();
        require(_exists(id), "ProofCardImplementation: URI set for nonexistent token");
        require(_isCreator(id, msg.sender), "ProofCardImplementation: caller is not creator");
        
        s.tokenURIs[id] = tokenURI;
        emit URI(tokenURI, id);
    }
    
    /**
     * @dev 设置基础URI
     */
    function setBaseURI(string memory newBaseURI) public {
        _getProofCardStorage().baseUri = newBaseURI;
    }
    
    /**
     * @dev 铸造新的NFT
     */
    function mint(address to, uint256 amount, bytes memory data) public returns (uint256) {
        ProofCardData storage s = _getProofCardStorage();
        require(to != address(0), "ProofCardImplementation: mint to zero address");
        
        uint256 tokenId = s.nextTokenId;
        s.nextTokenId += 1;
        
        _mint(to, tokenId, amount, data);
        s.creators[tokenId] = msg.sender;
        
        return tokenId;
    }
    
    /**
     * @dev 使用现有ID铸造更多NFT
     */
    function mintMore(address to, uint256 id, uint256 amount, bytes memory data) public {
        ProofCardData storage s = _getProofCardStorage();
        require(to != address(0), "ProofCardImplementation: mint to zero address");
        require(_exists(id), "ProofCardImplementation: token ID does not exist");
        require(_isCreator(id, msg.sender), "ProofCardImplementation: not token creator");
        
        _mint(to, id, amount, data);
    }
    
    /**
     * @dev 内部铸造实现
     */
    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal {
        ProofCardData storage s = _getProofCardStorage();
        s.balances[id][to] += amount;
        
        emit TransferSingle(msg.sender, address(0), to, id, amount);
        
        _doSafeTransferAcceptanceCheck(msg.sender, address(0), to, id, amount, data);
    }
    
    /**
     * @dev 单个NFT转账
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        ProofCardData storage s = _getProofCardStorage();
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCardImplementation: not owner nor approved"
        );
        require(to != address(0), "ProofCardImplementation: transfer to zero address");
        
        uint256 fromBalance = s.balances[id][from];
        require(fromBalance >= amount, "ProofCardImplementation: insufficient balance");
        
        s.balances[id][from] = fromBalance - amount;
        s.balances[id][to] += amount;
        
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
    ) public {
        ProofCardData storage s = _getProofCardStorage();
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCardImplementation: not owner nor approved"
        );
        require(to != address(0), "ProofCardImplementation: transfer to zero address");
        require(ids.length == amounts.length, "ProofCardImplementation: ids/amounts mismatch");
        
        for(uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            
            uint256 fromBalance = s.balances[id][from];
            require(fromBalance >= amount, "ProofCardImplementation: insufficient balance");
            
            s.balances[id][from] = fromBalance - amount;
            s.balances[id][to] += amount;
        }
        
        emit TransferBatch(msg.sender, from, to, ids, amounts);
        
        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }
    
    /**
     * @dev 检查代币ID是否存在
     */
    function _exists(uint256 id) internal view returns (bool) {
        return _getProofCardStorage().creators[id] != address(0);
    }
    
    /**
     * @dev 检查是否为代币创建者
     */
    function _isCreator(uint256 id, address account) internal view returns (bool) {
        return _getProofCardStorage().creators[id] == account;
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
    ) private {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ProofCardImplementation: ERC1155Receiver rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCardImplementation: transfer to non-receiver");
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
    ) private {
        if(to.code.length > 0) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ProofCardImplementation: ERC1155Receiver rejected");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCardImplementation: transfer to non-receiver");
            }
        }
    }
    
    /**
     * @dev 支持的接口查询
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0xd9b67a26 || // ERC-1155
            interfaceId == 0x01ffc9a7;   // ERC-165
    }
} 