// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockUSDC
 * @dev 用于测试的模拟USDC代币
 */
contract MockUSDC is ERC20, Ownable {
    uint8 private _decimals = 6;

    constructor() ERC20("Mock USDC", "MUSDC") Ownable(msg.sender) {
        // 初始铸造1,000,000 USDC给部署者
        _mint(msg.sender, 1_000_000 * 10**_decimals);
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev 允许任何人铸造代币（仅用于测试）
     * @param to 接收代币的地址
     * @param amount 铸造数量
     */
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
} 