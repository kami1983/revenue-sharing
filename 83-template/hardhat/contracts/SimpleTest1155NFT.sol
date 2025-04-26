// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleTest1155NFT
 * @dev 简化版ERC1155实现，减少代码体积
 */
contract SimpleTest1155NFT {
    // 代币URI
    string private _uri;
    
    // 所有者到代币ID到余额的映射
    mapping(address => mapping(uint256 => uint256)) private _balances;
    
    // 代币ID到总供应量的映射
    mapping(uint256 => uint256) private _totalSupply;
    
    // 所有者到操作员的授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // 事件
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    
    constructor(string memory uri_) {
        _uri = uri_;
        // 为发送者铸造100个ID为0的代币
        _mint(msg.sender, 0, 100);
    }
    
    // 返回代币URI
    function uri(uint256) public view returns (string memory) {
        return _uri;
    }
    
    // 查询余额
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ERC1155: address zero query");
        return _balances[account][id];
    }
    
    // 批量查询余额
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
        
        uint256[] memory batchBalances = new uint256[](accounts.length);
        
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        
        return batchBalances;
    }
    
    // 批准所有代币操作
    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    // 检查批准状态
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }
    
    // 安全转移
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }
    
    // 批量安全转移
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }
    
    // 内部转移实现
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        require(to != address(0), "ERC1155: transfer to the zero address");
        
        _beforeTokenTransfer(from, to, id, amount);
        
        uint256 fromBalance = _balances[from][id];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[from][id] = fromBalance - amount;
        }
        _balances[to][id] += amount;
        
        emit TransferSingle(msg.sender, from, to, id, amount);
    }
    
    // 内部批量转移实现
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            
            uint256 fromBalance = _balances[from][id];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[from][id] = fromBalance - amount;
            }
            _balances[to][id] += amount;
        }
        
        emit TransferSingle(msg.sender, from, to, ids[0], amounts[0]);
    }
    
    // 铸造代币
    function _mint(address to, uint256 id, uint256 amount) internal {
        require(to != address(0), "ERC1155: mint to the zero address");
        
        _beforeTokenTransfer(address(0), to, id, amount);
        
        _balances[to][id] += amount;
        _totalSupply[id] += amount;
        
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }
    
    // 代币转移前的钩子
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) internal virtual {}
} 