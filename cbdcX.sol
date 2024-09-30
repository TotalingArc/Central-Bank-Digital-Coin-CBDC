mapping(address => uint256) private stakedAt;
mapping(address => uint256) private stakedBalances;

function stakeTreasuryBonds(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero");
    require(balanceOf(msg.sender) >= amount, "Insufficient balance");
    _transfer(msg.sender, address(this), amount);
    
    stakedBalances[msg.sender] += amount;
    stakedAt[msg.sender] = block.timestamp;
    
    emit TreasuryBondsStaked(msg.sender, amount);
}

function unstakeTreasuryBonds(uint256 amount) external {
    require(amount > 0, "Amount must be greater than zero");
    require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
    
    stakedBalances[msg.sender] -= amount;
    _transfer(address(this), msg.sender, amount);
    
    emit TreasuryBondsUnstaked(msg.sender, amount);
}

function claimTreasuryBonds() external {
    require(!_blacklist[msg.sender], "Sender is blacklisted");
    uint256 stakedBalance = stakedBalances[msg.sender];
    require(stakedBalance > 0, "No staked balance");
    
    uint256 secondsStaked = block.timestamp - stakedAt[msg.sender];
    uint256 rewards = (stakedBalance * secondsStaked * interestRateBasisPoints) / (10000 * 365 days);
    
    _mint(msg.sender, rewards);
    emit TreasuryBondsClaimed(msg.sender, rewards);
}
