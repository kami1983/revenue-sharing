// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ProofCardBase
 * @dev 基础合约，包含核心数据结构和基本函数
 */
contract ProofCardBase {
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
    mapping(uint256 => mapping(address => uint256)) internal _balances;
    
    // 映射：账户 => (操作者 => 是否批准)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    
    // 下一个可用的tokenId
    uint256 internal _nextTokenId = 1;
    
    /**
     * @dev 构造函数
     * @param tokenName 合约名称
     */
    constructor(string memory tokenName) {
        name = tokenName;
    }
    
    /**
     * @dev 返回账户在指定代币ID下的余额
     */
    function balanceOf(address account, uint256 id) public view returns (uint256) {
        require(account != address(0), "ProofCard: balance query for zero address");
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
        require(accounts.length == ids.length, "ProofCard: accounts/ids length mismatch");
        
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
     * @dev 支持的接口查询
     */
    function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0xd9b67a26 || // ERC-1155
            interfaceId == 0x01ffc9a7;   // ERC-165
    }
} 