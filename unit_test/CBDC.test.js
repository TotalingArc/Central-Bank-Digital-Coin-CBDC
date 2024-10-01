const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Central Bank Digital Coin (CBDC)", function () {
  let CBDC, cbdc, owner, governance, admin, user1, user2;

  beforeEach(async () => {
    [owner, governance, admin, user1, user2] = await ethers.getSigners();
    CBDC = await ethers.getContractFactory("CentralBankDigitalCoin");
    cbdc = await CBDC.deploy(governance.address, ethers.utils.parseUnits("1000", 18));
    await cbdc.deployed();

    // Grant admin role to admin signer
    await cbdc.grantRole(await cbdc.ADMIN_ROLE(), admin.address);
  });

  describe("Deployment", function () {
    it("Should set the correct governance and admin roles", async () => {
      expect(await cbdc.hasRole(await cbdc.GOVERNANCE_ROLE(), governance.address)).to.be.true;
      expect(await cbdc.hasRole(await cbdc.ADMIN_ROLE(), admin.address)).to.be.true;
    });

    it("Should assign the initial supply to governance", async () => {
      const initialSupply = await cbdc.totalSupply();
      expect(await cbdc.balanceOf(governance.address)).to.equal(initialSupply);
    });
  });

  describe("Interest Rate Updates", function () {
    it("Should allow governance to update the interest rate", async () => {
      const newInterestRate = 600; // 6% in basis points
      await cbdc.connect(governance).updateInterestRate(newInterestRate);
      expect(await cbdc.interestRateBasisPoints()).to.equal(newInterestRate);
    });

    it("Should not allow non-governance to update the interest rate", async () => {
      await expect(
        cbdc.connect(user1).updateInterestRate(700)
      ).to.be.revertedWith("AccessControl: account");
    });
  });

  describe("Money Supply Control", function () {
    it("Should allow governance to increase the money supply", async () => {
      const inflationAmount = ethers.utils.parseUnits("500", 18);
      const totalSupplyBefore = await cbdc.totalSupply();
      await cbdc.connect(governance).increaseMoneySupply(inflationAmount);
      const totalSupplyAfter = await cbdc.totalSupply();
      expect(totalSupplyAfter.sub(totalSupplyBefore)).to.equal(inflationAmount);
    });

    it("Should not allow non-governance to increase the money supply", async () => {
      const inflationAmount = ethers.utils.parseUnits("500", 18);
      await expect(
        cbdc.connect(user1).increaseMoneySupply(inflationAmount)
      ).to.be.revertedWith("AccessControl: account");
    });
  });

  describe("Blacklist", function () {
    it("Should allow admin to update blacklist status", async () => {
      await cbdc.connect(admin).updateBlacklist(user1.address, true);
      expect(await cbdc.isBlacklisted(user1.address)).to.be.true;
    });

    it("Should prevent blacklisted address from claiming rewards", async () => {
      await cbdc.connect(admin).updateBlacklist(user1.address, true);
      await expect(
        cbdc.connect(user1).claimTreasuryBonds()
      ).to.be.revertedWith("Sender is blacklisted");
    });
  });

  describe("Treasury Bonds", function () {
    beforeEach(async () => {
      // Transfer tokens from governance to user1 for staking
      const transferAmount = ethers.utils.parseUnits("100", 18);
      await cbdc.connect(governance).transfer(user1.address, transferAmount);
    });

    it("Should allow users to stake treasury bonds", async () => {
      const stakeAmount = ethers.utils.parseUnits("50", 18);
      await cbdc.connect(user1).stakeTreasuryBonds(stakeAmount);
      expect(await cbdc.balanceOf(user1.address)).to.equal(ethers.utils.parseUnits("50", 18));
      expect(await cbdc.balanceOf(cbdc.address)).to.equal(stakeAmount);
    });

    it("Should allow users to unstake treasury bonds", async () => {
      const stakeAmount = ethers.utils.parseUnits("50", 18);
      await cbdc.connect(user1).stakeTreasuryBonds(stakeAmount);
      await cbdc.connect(user1).unstakeTreasuryBonds(stakeAmount);
      expect(await cbdc.balanceOf(user1.address)).to.equal(ethers.utils.parseUnits("100", 18));
    });

    it("Should calculate and distribute rewards when claiming treasury bonds", async () => {
      const stakeAmount = ethers.utils.parseUnits("50", 18);
      await cbdc.connect(user1).stakeTreasuryBonds(stakeAmount);

      // Simulate passing of time
      const stakeTimestamp = (await ethers.provider.getBlock()).timestamp;
      await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]); // 1 year
      await ethers.provider.send("evm_mine", []);

      // Claim rewards
      await cbdc.connect(user1).claimTreasuryBonds();
      const rewards = (stakeAmount.mul(500)).div(10000); // 5% annual interest
      expect(await cbdc.balanceOf(user1.address)).to.equal(ethers.utils.parseUnits("50", 18).add(rewards));
    });
  });

  describe("Pausable Functionality", function () {
    it("Should allow admin to pause and unpause", async () => {
      await cbdc.connect(admin).pause();
      await expect(
        cbdc.connect(user1).transfer(user2.address, ethers.utils.parseUnits("1", 18))
      ).to.be.revertedWith("ERC20Pausable: token transfer while paused");

      await cbdc.connect(admin).unpause();
      await cbdc.connect(user1).transfer(user2.address, ethers.utils.parseUnits("1", 18));
      expect(await cbdc.balanceOf(user2.address)).to.equal(ethers.utils.parseUnits("1", 18));
    });

    it("Should not allow non-admin to pause or unpause", async () => {
      await expect(cbdc.connect(user1).pause()).to.be.revertedWith("AccessControl: account");
    });
  });
});
