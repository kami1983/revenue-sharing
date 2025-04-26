// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ProofCard
 * @dev 一个简化版的ERC-1155 NFT实现
 */
contract ProofCard {
    // 事件
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    
    event URI(string value, uint256 indexed id);
    
    // 合约名称
    string public name;
    
    // 映射：tokenId => (账户 => 余额)
    mapping(uint256 => mapping(address => uint256)) private _balances;
    
    // 映射：账户 => (操作者 => 是否批准)
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // 基础URI
    string private _uri;
    
    // NFT元数据
    mapping(uint256 => string) private _tokenURIs;
    
    // NFT创建者
    mapping(uint256 => address) private _creators;
    
    // 下一个可用的tokenId
    uint256 private _nextTokenId = 1;
    
    /**
     * @dev 构造函数
     * @param tokenName 合约名称
     * @param baseURI 基础URI
     */
    constructor(string memory tokenName, string memory baseURI) {
        name = tokenName;
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
        require(_isCreator(id, msg.sender), "ProofCard: caller is not token creator");
        
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
     * @dev 返回账户在指定代币ID下的余额
     */
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ProofCard: balance query for the zero address");
        return _balances[id][account];
    }
    
    /**
     * @dev 批量返回账户在多个代币ID下的余额
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ProofCard: accounts and ids length mismatch");
        
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
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    /**
     * @dev 查询操作者是否被账户批准
     */
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }
    
    /**
     * @dev 铸造新的NFT
     * @param to 接收者地址
     * @param amount 铸造数量
     * @param data 附加数据
     * @return 新铸造的代币ID
     */
    function mint(address to, uint256 amount, bytes memory data) public returns (uint256) {
        require(to != address(0), "ProofCard: mint to the zero address");
        
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
        require(to != address(0), "ProofCard: mint to the zero address");
        require(_exists(id), "ProofCard: token ID does not exist");
        require(_isCreator(id, msg.sender), "ProofCard: caller is not token creator");
        
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
     * @dev 单个NFT转账
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCard: caller is not owner nor approved"
        );
        require(to != address(0), "ProofCard: transfer to the zero address");
        
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ProofCard: insufficient balance for transfer");
        
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
    ) public {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ProofCard: caller is not owner nor approved"
        );
        require(to != address(0), "ProofCard: transfer to the zero address");
        require(ids.length == amounts.length, "ProofCard: ids and amounts length mismatch");
        
        for(uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            
            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ProofCard: insufficient balance for transfer");
            
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }
        
        emit TransferBatch(msg.sender, from, to, ids, amounts);
        
        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
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
                    revert("ProofCard: ERC1155Receiver returned invalid value");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCard: transfer to non ERC1155Receiver implementer");
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
                    revert("ProofCard: ERC1155Receiver returned invalid value");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ProofCard: transfer to non ERC1155Receiver implementer");
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

/**
 * @dev ERC1155接收者接口
 */
interface IERC1155Receiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
    
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
} 