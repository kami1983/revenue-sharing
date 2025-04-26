// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title RevenueVault
 * @dev 收益分享保险库，允许NFT持有者分享所接收的资金
 */
contract RevenueVault is ERC721Enumerable, Ownable {
    // 保存每个代币最后一次索取的时间点
    mapping(uint256 => uint256) private lastClaimTimestamp;
    
    // 每个地址的待领取资金 (代币地址 => 用户地址 => 金额)
    mapping(address => mapping(address => uint256)) private pendingRewards;
    
    // 支持的ERC20代币列表
    address[] public supportedTokens;
    
    // 每个代币的累计每股支付（乘以精度因子）
    mapping(address => uint256) private accumulatedPerShare;
    
    // 代币总供应量
    uint256 public constant MAX_SUPPLY = 1000;
    
    // 已铸造的NFT数量
    uint256 public tokensMinted = 0;
    
    // 铸造NFT的价格
    uint256 public mintPrice = 0.01 ether;
    
    // 精度因子，用于避免整数除法的精度损失
    uint256 private constant PRECISION_FACTOR = 1e18;
    
    // 分配事件
    event Distribution(address tokenAddress, uint256 amount, uint256 perShare);
    
    // 领取事件
    event Claimed(address user, address token, uint256 amount);
    
    /**
     * @dev 构造函数
     */
    constructor() ERC721("VaultNFT", "VNFT") Ownable(msg.sender) {
        // 初始化支持的代币列表，可以根据需要添加更多代币
        supportedTokens.push(address(0)); // ETH
    }
    
    /**
     * @dev 铸造NFT
     * @param amount 要铸造的数量
     */
    function mint(uint256 amount) external payable {
        require(tokensMinted + amount <= MAX_SUPPLY, "Max supply exceeded");
        require(msg.value >= mintPrice * amount, "Insufficient ETH sent");
        
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokensMinted + 1;
            _safeMint(msg.sender, tokenId);
            lastClaimTimestamp[tokenId] = block.timestamp;
            tokensMinted++;
        }
    }
    
    /**
     * @dev 添加支持的ERC20代币
     * @param tokenAddress 代币地址
     */
    function addSupportedToken(address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Cannot add ETH again");
        
        // 确保代币尚未添加
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            require(supportedTokens[i] != tokenAddress, "Token already supported");
        }
        
        supportedTokens.push(tokenAddress);
    }
    
    /**
     * @dev 接收ETH
     */
    receive() external payable {
        if (msg.value > 0 && totalSupply() > 0) {
            _distributeToken(address(0), msg.value);
        }
    }
    
    /**
     * @dev 触发收入分配（任何代币持有者都可以触发）
     * @param tokenAddress 要分配的代币地址，address(0)表示ETH
     */
    function triggerDistribution(address tokenAddress) external {
        require(balanceOf(msg.sender) > 0, "Must own a VaultNFT");
        
        bool isSupported = false;
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == tokenAddress) {
                isSupported = true;
                break;
            }
        }
        require(isSupported, "Token not supported");
        
        uint256 balance;
        
        if (tokenAddress == address(0)) {
            balance = address(this).balance;
        } else {
            balance = IERC20(tokenAddress).balanceOf(address(this));
        }
        
        require(balance > 0, "No tokens to distribute");
        
        _distributeToken(tokenAddress, balance);
    }
    
    /**
     * @dev 内部函数：分配代币
     * @param tokenAddress 代币地址
     * @param amount 金额
     */
    function _distributeToken(address tokenAddress, uint256 amount) private {
        uint256 tokenSupply = totalSupply();
        require(tokenSupply > 0, "No tokens minted yet");
        
        uint256 amountPerShare = (amount * PRECISION_FACTOR) / tokenSupply;
        accumulatedPerShare[tokenAddress] = accumulatedPerShare[tokenAddress] + amountPerShare;
        
        emit Distribution(tokenAddress, amount, amountPerShare);
    }
    
    /**
     * @dev 领取待领取的代币
     * @param tokenAddress 代币地址
     */
    function claim(address tokenAddress) external {
        uint256 userBalance = balanceOf(msg.sender);
        require(userBalance > 0, "Must own VaultNFT");
        
        uint256 totalReward = 0;
        
        for (uint256 i = 0; i < userBalance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(msg.sender, i);
            uint256 reward = _calculateReward(tokenAddress, tokenId);
            
            if (reward > 0) {
                totalReward = totalReward + reward;
                lastClaimTimestamp[tokenId] = block.timestamp;
            }
        }
        
        require(totalReward > 0, "No rewards to claim");
        
        if (tokenAddress == address(0)) {
            // 发送ETH
            (bool success, ) = payable(msg.sender).call{value: totalReward}("");
            require(success, "ETH transfer failed");
        } else {
            // 发送ERC20代币
            require(IERC20(tokenAddress).transfer(msg.sender, totalReward), "Token transfer failed");
        }
        
        emit Claimed(msg.sender, tokenAddress, totalReward);
    }
    
    /**
     * @dev 内部函数：计算待领取的奖励
     * @param tokenAddress 代币地址
     * @param tokenId NFT的ID
     * @return 待领取的奖励
     */
    function _calculateReward(address tokenAddress, uint256 tokenId) private view returns (uint256) {
        uint256 lastTimestamp = lastClaimTimestamp[tokenId];
        uint256 currentAccumulated = accumulatedPerShare[tokenAddress];
        
        // 使用累积每股分配来计算奖励
        uint256 reward = currentAccumulated / PRECISION_FACTOR;
        
        return reward;
    }
    
    /**
     * @dev 检查代币是否存在
     * @param tokenId 代币ID
     * @return 是否存在
     */
    function _tokenExists(uint256 tokenId) private view returns (bool) {
        return tokenId > 0 && tokenId <= tokensMinted && ownerOf(tokenId) != address(0);
    }
    
    /**
     * @dev 查看某个代币ID可领取的奖励
     * @param tokenAddress 代币地址
     * @param tokenId 代币ID
     * @return 可领取的奖励
     */
    function pendingReward(address tokenAddress, uint256 tokenId) external view returns (uint256) {
        require(_tokenExists(tokenId), "Token does not exist");
        return _calculateReward(tokenAddress, tokenId);
    }
    
    /**
     * @dev 查看地址拥有的所有NFT可领取的奖励总和
     * @param tokenAddress 代币地址
     * @param user 用户地址
     * @return 可领取的奖励总和
     */
    function pendingRewardAll(address tokenAddress, address user) external view returns (uint256) {
        uint256 userBalance = balanceOf(user);
        uint256 totalReward = 0;
        
        for (uint256 i = 0; i < userBalance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(user, i);
            totalReward = totalReward + _calculateReward(tokenAddress, tokenId);
        }
        
        return totalReward;
    }
    
    /**
     * @dev 设置铸造价格
     * @param newPrice 新价格
     */
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }
    
    /**
     * @dev 提取合约中的ETH（管理员功能）
     * @param amount 提取金额
     */
    function withdrawETH(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");
    }
} 