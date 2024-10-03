// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./CentralBankDigitalCoin.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Treasury is AccessControl {
    CentralBankDigitalCoin public cbdc;

    // Access control role for admin
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // Struct to keep track of each user's staking information
    struct StakingInfo {
        uint256 stakedAmount;
        uint256 stakedAt;
    }

    // Mapping of address to staking information
    mapping(address => StakingInfo) public stakingData;

    // Events
    event Staked(address indexed account, uint256 amount);
    event Unstaked(address indexed account, uint256 amount);
    event Claimed(address indexed account, uint256 reward);

    // Constructor to link CBDC contract and assign roles
    constructor(address cbdcAddress) {
        cbdc = CentralBankDigitalCoin(cbdcAddress);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    // Stake CBDC tokens as treasury bonds
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(cbdc.balanceOf(msg.sender) >= amount, "Insufficient CBDC balance");

        StakingInfo storage staker = stakingData[msg.sender];

        // Transfer CBDC tokens to the treasury contract
        cbdc.transferFrom(msg.sender, address(this), amount);

        // Update the staking data
        staker.stakedAmount += amount;
        staker.stakedAt = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    // Unstake treasury bonds (CBDC tokens)
    function unstake(uint256 amount) external {
        StakingInfo storage staker = stakingData[msg.sender];
        require(staker.stakedAmount >= amount, "Insufficient staked balance");

        // Update staking data
        staker.stakedAmount -= amount;

        // Transfer CBDC tokens back to the user
        cbdc.transfer(msg.sender, amount);

        emit Unstaked(msg.sender, amount);
    }

    // Claim staking rewards based on the interest rate
    function claimRewards() external {
        StakingInfo storage staker = stakingData[msg.sender];
        require(staker.stakedAmount > 0, "No staked amount");
        require(cbdc.isBlacklisted(msg.sender) == false, "Sender is blacklisted");

        // Calculate rewards: (stakedAmount * interestRate * time) / (10000 basis points * 365 days)
        uint256 timeStaked = block.timestamp - staker.stakedAt;
        uint256 interestRateBasisPoints = cbdc.interestRateBasisPoints();
        uint256 rewards = (staker.stakedAmount * timeStaked * interestRateBasisPoints) / (10000 * 365 days);

        // Mint rewards to the user's wallet
        cbdc.mint(msg.sender, rewards);

        // Reset staked time for future reward calculations
        staker.stakedAt = block.timestamp;

        emit Claimed(msg.sender, rewards);
    }

    // Admin function to withdraw remaining tokens in case of emergency
    function emergencyWithdraw(uint256 amount) external onlyRole(ADMIN_ROLE) {
        require(cbdc.balanceOf(address(this)) >= amount, "Insufficient contract balance");
        cbdc.transfer(msg.sender, amount);
    }
}

