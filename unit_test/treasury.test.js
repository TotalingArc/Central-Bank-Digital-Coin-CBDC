const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Treasury Contract", function () {
  let CBDC, cbdc, Treasury, treasury, owner, staker1, staker2, admin;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here
    [owner, staker1, staker2, admin] = await ethers.getSigners();

    // Deploy the CBDC Contract
    CBDC = await ethers.getContractFactory("CentralBankDigitalCoin");
    cbdc = await CBDC.deploy(owner.address, ethers.utils.parseEther("1000000")); // 1M initial supply

    // Deploy the Treasury Contract
    Treasury = await ethers.getContractFactory("Treasury");
    treasury = await Treasury.deploy(cbdc.address);

    // Transfer role to the admin for testing
    await treasury.grantRole(await treasury.ADMIN_ROLE(), admin.address);

    // Allocate initial tokens to stakers
    await cbdc.transfer(staker1.address, ethers.utils.parseEther("1000"));
    await cbdc.transfer(staker2.address, ethers.utils.parseEther("1000"));

    // Approve Treasury to spend CBDC tokens on behalf of stakers
    await cbdc.connect(staker1).approve(treasury.address, ethers.utils.parseEther("1000"));
    await cbdc.connect(staker2).approve(treasury.address, ethers.utils.parseEther("1000"));
  });

  it("should stake tokens", async function () {
    // Staker 1 stakes 100 CBDC tokens
    await treasury.connect(staker1).stake(ethers.utils.parseEther("100"));

    const stakingInfo = await treasury.stakingData(staker1.address);
    expect(stakingInfo.stakedAmount).to.equal(ethers.utils.parseEther("100"));
  });

  it("should unstake tokens", async function () {
    // Staker 1 stakes and unstakes tokens
    await treasury.connect(staker1).stake(ethers.utils.parseEther("100"));
    await treasury.connect(staker1).unstake(ethers.utils.parseEther("50"));

    const stakingInfo = await treasury.stakingData(staker1.address);
    expect(stakingInfo.stakedAmount).to.equal(ethers.utils.parseEther("50"));

    // Ensure CBDC balance is correctly updated
    const stakerBalance = await cbdc.balanceOf(staker1.address);
    expect(stakerBalance).to.equal(ethers.utils.parseEther("950"));
  });

  it("should calculate and claim rewards correctly", async function () {
    // Staker 1 stakes tokens and claims rewards after some time
    await treasury.connect(staker1).stake(ethers.utils.parseEther("100"));

    // Advance time by 365 days (simulating 1 year)
    await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine", []); // mine the next block

    // Claim rewards
    await treasury.connect(staker1).claimRewards();

    // Rewards should be minted and sent to staker1 based on interest rate
    const stakerBalance = await cbdc.balanceOf(staker1.address);
    expect(stakerBalance).to.be.above(ethers.utils.parseEther("900")); // considering some interest
  });

  it("should prevent blacklisted users from claiming rewards", async function () {
    // Staker 1 stakes tokens
    await treasury.connect(staker1).stake(ethers.utils.parseEther("100"));

    // Blacklist staker 1 in the CBDC contract
    await cbdc.connect(owner).updateBlacklist(staker1.address, true);

    // Attempt to claim rewards should revert
    await expect(treasury.connect(staker1).claimRewards()).to.be.revertedWith("Sender is blacklisted");
  });

  it("should allow only admin to emergency withdraw tokens", async function () {
    // Staker 1 stakes tokens
    await treasury.connect(staker1).stake(ethers.utils.parseEther("100"));

    // Emergency withdraw by admin
    await treasury.connect(admin).emergencyWithdraw(ethers.utils.parseEther("50"));

    // Admin's balance should now include the withdrawn tokens
    const adminBalance = await cbdc.balanceOf(admin.address);
    expect(adminBalance).to.equal(ethers.utils.parseEther("50"));
  });

  it("should not allow non-admin to perform emergency withdraw", async function () {
    // Staker 1 tries to emergency withdraw, which should fail
    await expect(treasury.connect(staker1).emergencyWithdraw(ethers.utils.parseEther("50"))).to.be.revertedWith(
      `AccessControl: account ${staker1.address.toLowerCase()} is missing role`
    );
  });
});
