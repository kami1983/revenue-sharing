// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Modular1155NFTCore
 * @dev 核心1155功能
 */
contract Modular1155NFTCore {
    // 代币URI
    string private _uri;
    
    // 所有者到代币ID到余额的映射
    mapping(address => mapping(uint256 => uint256)) private _balances;
    
    // 代币ID到总供应量的映射
    mapping(uint256 => uint256) private _totalSupply;
    
    // 事件
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    
    constructor(string memory uri_) {
        _uri = uri_;
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
    
    // 内部铸造函数
    function _mint(address to, uint256 id, uint256 amount) internal {
        require(to != address(0), "ERC1155: mint to the zero address");
        
        _balances[to][id] += amount;
        _totalSupply[id] += amount;
        
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }
    
    // 内部销毁函数
    function _burn(address from, uint256 id, uint256 amount) internal {
        require(from != address(0), "ERC1155: burn from the zero address");
        
        uint256 fromBalance = _balances[from][id];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[from][id] = fromBalance - amount;
        }
        _totalSupply[id] -= amount;
        
        emit TransferSingle(msg.sender, from, address(0), id, amount);
    }
}

/**
 * @title Modular1155NFTPermissions
 * @dev 权限管理模块
 */
contract Modular1155NFTPermissions {
    // 所有者到操作员的授权映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    // 事件
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    
    // 批准所有代币操作
    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    // 检查批准状态
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _operatorApprovals[account][operator];
    }
}

/**
 * @title Modular1155NFT
 * @dev 将所有模块组合的主合约
 */
contract Modular1155NFT {
    Modular1155NFTCore private _core;
    Modular1155NFTPermissions private _permissions;
    
    constructor() {
        // 部署子合约
        _core = new Modular1155NFTCore("https://game.example/api/item/{id}.json");
        _permissions = new Modular1155NFTPermissions();
        
        // 为创建者铸造初始NFT
        mint(msg.sender, 0, 100);
    }
    
    // URI查询
    function uri(uint256 id) public view returns (string memory) {
        return _core.uri(id);
    }
    
    // 余额查询
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        return _core.balanceOf(account, id);
    }
    
    // 批量余额查询
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) public view returns (uint256[] memory) {
        return _core.balanceOfBatch(accounts, ids);
    }
    
    // 设置授权
    function setApprovalForAll(address operator, bool approved) public {
        _permissions.setApprovalForAll(operator, approved);
    }
    
    // 检查授权
    function isApprovedForAll(address account, address operator) public view returns (bool) {
        return _permissions.isApprovedForAll(account, operator);
    }
    
    // 铸造代币
    function mint(address to, uint256 id, uint256 amount) public {
        // 这里可以添加权限检查
        address coreAddress = address(_core);
        bytes memory data = abi.encodeWithSignature("_mint(address,uint256,uint256)", to, id, amount);
        (bool success, ) = coreAddress.call(data);
        require(success, "Mint failed");
    }
} 