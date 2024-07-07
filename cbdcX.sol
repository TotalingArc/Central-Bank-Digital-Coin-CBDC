// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract CentralBankDigitalCoin is ERC20, ERC20Burnable, Pausable, AccessControl {
    // Access control roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    // Interest rate in basis points (0.01% increments)
    uint256 public interestRateBasisPoints = 500; // 5% expressed in basis points

    // Blacklisted addresses//
    mapping(address => bool) private _blacklist;

    // Events
    event InterestRateUpdated(uint256 oldInterestRate, uint256 newInterestRate);
    event IncreaseMoneySupply(uint256 inflationAmount);
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event TreasuryBondsStaked(address indexed account, uint256 amount);
    event TreasuryBondsUnstaked(address indexed account, uint256 amount);
    event TreasuryBondsClaimed(address indexed account, uint256 amount);

    constructor(address initialGovernance, uint256 initialSupply) ERC20("Central Bank Digital Currency", "CBDC") {
        _setupRole(GOVERNANCE_ROLE, initialGovernance);
        _setupRole(ADMIN_ROLE, msg.sender);
        _mint(initialGovernance, initialSupply);
    }

    function updateInterestRate(uint256 newInterestRateBasisPoints) external onlyRole(GOVERNANCE_ROLE) {
        emit InterestRateUpdated(interestRateBasisPoints, newInterestRateBasisPoints);
        interestRateBasisPoints = newInterestRateBasisPoints;
    }

    function increaseMoneySupply(uint256 inflationAmount) external onlyRole(GOVERNANCE_ROLE) {
        emit IncreaseMoneySupply(inflationAmount);
        _mint(msg.sender, inflationAmount);
    }

    function updateBlacklist(address account, bool isBlacklisted) external onlyRole(ADMIN_ROLE) {
        _blacklist[account] = isBlacklisted;
        emit BlacklistUpdated(account, isBlacklisted);
    }

    function stakeTreasuryBonds(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        emit TreasuryBondsStaked(msg.sender, amount);
    }

    function unstakeTreasuryBonds(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(balanceOf(address(this)) >= amount, "Insufficient staked balance");
        _transfer(address(this), msg.sender, amount);
        emit TreasuryBondsUnstaked(msg.sender, amount);
    }

    function claimTreasuryBonds() external {
        require(_blacklist[msg.sender] == false, "Sender is blacklisted");
        uint256 stakedBalance = balanceOf(address(this));
        require(stakedBalance > 0, "No staked balance");
        uint256 secondsStaked = block.timestamp - stakedAt[msg.sender];
        uint256 rewards = (stakedBalance * secondsStaked * interestRateBasisPoints) / (10000 * 365 days);
        _mint(msg.sender, rewards);
        emit TreasuryBondsClaimed(msg.sender, rewards);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist[account];
    }

    // Overrides
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        require(!paused(), "ERC20Pausable: token transfer while paused");
        super._beforeTokenTransfer(from, to, amount);
    }
}
