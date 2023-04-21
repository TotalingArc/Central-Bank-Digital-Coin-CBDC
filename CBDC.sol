// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract CentralBankDigitalCoin is ERC20, ERC20Burnable, Pausable, Ownable, ERC20FlashMint {
    //state variables

    //governance wallet
    address public governance;
    //Integer for Intrests Rate of CBDC
    uint public interestRateBasisPoints = 500; // 5% of Basis Point

    //blacklist addresses
    mapping(address => bool) public blacklist;
    //Allow staking participation list
    mapping(address => uint) private stakedTreasuryBond;
    //store timestamp staking start
    mapping(address => uint) private stakedfromTS;

    //Define events to keep track of all data changes(Re-construct History)

    //Update Governance
    event UpdateGovernance(address oldGovernance, address newGovernance);
    //Update Interest Rate
    event UpdateInterestRate(uint oldInterest, uint newInterestRate);
    //When theres an Increase in Money Supply
    event IncreaseMoneySupply(uint oldMoneySupply, uint inflationAmount);
    //Update to Blacklist (historical)
    event UpdateBlacklist(address criminal, bool blocked);
    //stake
    event StakedTreasuryBonds(address user, uint amount);
    //Un-stake
    event UnstakeTreasuryBonds(address user, uint amount);
    //Claim
    event ClaimTreasuryBonds(address user, uint amount);

    constructor(
        address _governance,
        uint initialSupply
    ) ERC20("Central Bank Digital Currency", "CBDC") {
        governance = _governance;
        _mint(governance, initialSupply);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}

    function updateGovernance(address newGovernance) external {
        require(msg.sender == governance, "NOT GOVERNING PARTY");
        governance = newGovernance;
        _transfer(governance, newGovernance, balanceOf(governance));
        emit UpdateGovernance(msg.sender, newGovernance);
    }

    function updateInterestRate(uint newInterestRateBasisPoints) external {
        require(msg.sender == governance, "NOT GOVERNING PARTY");
        uint oldInterestRateBasisPoints = interestRateBasisPoints;
        interestRateBasisPoints = newInterestRateBasisPoints;
        emit UpdateInterestRate(
            oldInterestRateBasisPoints,
            newInterestRateBasisPoints
        );
    }

    function increaseMoneySupply(uint inflationAmount) external {
        require(msg.sender == governance, "NOT GOVERNING PARTY");
        uint oldMoneySupply = totalSupply();
        _mint(msg.sender, inflationAmount);
        emit IncreaseMoneySupply(oldMoneySupply, inflationAmount);
    }

    function updateBlacklist(address criminal, bool blacklisted) external {
        require(msg.sender == governance, "NOT GOVERNING PARTY");
        blacklist[criminal] = blacklisted;
        emit UpdateBlacklist(criminal, blacklisted);
    }

    function StakedTreasuryBond(uint amount) external {
        require(amount > 0, "amount is <= 0");
        require(balanceOf(msg.sender) >= amount, "balance is <= amount");
        _transfer(msg.sender, address(this), amount);
        if (stakedTreasuryBond[msg.sender] > 0) claimTreasuryBonds();
        stakedfromTS[msg.sender] = block.timestamp;
        stakedTreasuryBond[msg.sender] += amount;
        emit StakedTreasuryBonds(msg.sender, amount);
    }

    function unstakeTreasuryBonds(uint amount) external {
        require(amount > 0, "amount is <= 0");
        require(stakedTreasuryBond[msg.sender] >= amount, "amount is > staked");
        claimTreasuryBonds();
        //Update mapping
        stakedTreasuryBond[msg.sender] -= amount;
        //transfer
        _transfer(address(this), msg.sender, amount);
        emit UnstakeTreasuryBonds(msg.sender, amount);
    }

    //Claim from staked coin
    function claimTreasuryBonds() public {
        require(stakedTreasuryBond[msg.sender] > 0, "staked is <= 0");
        uint secondsStaked = block.timestamp - stakedfromTS[msg.sender];
        uint rewards = (stakedTreasuryBond[msg.sender] *
            secondsStaked *
            interestRateBasisPoints) / (10000 * 3.154e7);
        stakedfromTS[msg.sender] = block.timestamp;
        _mint(msg.sender, rewards);
        emit ClaimTreasuryBonds(msg.sender, rewards);
    }

    // Overide for Blacklist
    function _transfer(
        address from,
        address to,
        uint amount
    ) internal virtual override {
        require(blacklist[from] == false, "Sender address is Blacklisted");
        require(blacklist[to] == false, "Sender address is Blacklisted");
        super._transfer(from, to, amount);
    }
}
