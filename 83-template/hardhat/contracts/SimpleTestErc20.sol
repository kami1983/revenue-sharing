// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SimpleTestErc20
 * @dev 一个简化版的ERC20代币实现，减少代码体积
 */
contract SimpleTestErc20 {
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
     * @param tokenName 代币名称
     * @param tokenSymbol 代币符号
     * @param tokenDecimals 代币小数位数
     * @param initialSupply 初始供应量
     */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 initialSupply
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        
        // 计算实际供应量，考虑小数位数
        uint256 supply = initialSupply * (10 ** uint256(tokenDecimals));
        
        // 初始化总供应量，并铸造给部署者
        _totalSupply = supply;
        _balances[msg.sender] = supply;
        
        emit Transfer(address(0), msg.sender, supply);
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
        address sender = msg.sender;
        _transfer(sender, to, amount);
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
        address spender = msg.sender;
        
        // 检查授权额度并更新
        uint256 currentAllowance = _allowances[from][spender];
        require(currentAllowance >= amount, "ERC20: insufficient allowance");
        
        _approve(from, spender, currentAllowance - amount);
        _transfer(from, to, amount);
        
        return true;
    }
    
    /**
     * @dev 增加授权额度
     * @param spender 被授权者地址
     * @param addedValue 增加的授权金额
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    /**
     * @dev 减少授权额度
     * @param spender 被授权者地址
     * @param subtractedValue 减少的授权金额
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    /**
     * @dev 内部转账实现
     */
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 senderBalance = _balances[from];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[from] = senderBalance - amount;
        _balances[to] += amount;
        
        emit Transfer(from, to, amount);
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
     * @dev 铸造功能，仅供演示，实际应用中应添加权限控制
     * @param to 接收者地址
     * @param amount 铸造金额
     */
    function mint(address to, uint256 amount) public {
        require(to != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balances[to] += amount;
        
        emit Transfer(address(0), to, amount);
    }
    
    /**
     * @dev 销毁功能
     * @param amount 销毁金额
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev 内部销毁实现
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        
        emit Transfer(account, address(0), amount);
    }
} 