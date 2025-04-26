// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleMinimalErc20
 * @dev 最小化ERC20代币实现，不依赖任何外部库
 */
contract SimpleMinimalErc20 {
    // 代币基本信息
    string public name;
    string public symbol;
    uint8 public decimals;
    
    // 代币总供应量
    uint256 private _totalSupply;
    
    // 账户余额映射
    mapping(address => uint256) private _balances;
    
    // 授权映射
    mapping(address => mapping(address => uint256)) private _allowances;
    
    // 事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    /**
     * @dev 构造函数，初始化代币信息并铸造初始供应量
     * @param name_ 代币名称
     * @param symbol_ 代币符号
     * @param decimals_ 代币小数位数
     * @param initialSupply_ 初始供应量
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        
        // 铸造给部署者
        _mint(msg.sender, initialSupply_);
    }
    
    /**
     * @dev 返回代币总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev 返回账户余额
     * @param account 要查询的账户地址
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev 转账函数
     * @param to 接收者地址
     * @param amount 转账金额
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    /**
     * @dev 返回授权额度
     * @param owner 授权者地址
     * @param spender 被授权者地址
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
     * @dev 授权功能
     * @param spender 被授权者地址
     * @param amount 授权金额
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    /**
     * @dev 授权转账功能
     * @param from 发送者地址
     * @param to 接收者地址
     * @param amount 转账金额
     */
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    /**
     * @dev 内部授权实现
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    /**
     * @dev 内部转账实现
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    /**
     * @dev 内部铸造实现
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev 内部销毁实现
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev 消耗授权额度
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    
    /**
     * @dev 铸造新的代币（可选，可以添加权限控制）
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
    
    /**
     * @dev 销毁代币
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev 代授权销毁代币
     */
    function burnFrom(address account, uint256 amount) public {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }
} 