# Central Bank Digital Coin (CBDC)

## Overview
This smart contract implements a Central Bank Digital Coin (CBDC) with the following key features:

- ERC20 Token Standard: The token follows the ERC20 standard, with additional burn and pause functionalities.
- Role-based Access Control: Administrators and governance entities can control actions such as interest rate adjustments, money supply inflation, and blacklisting of accounts.
- Staking of Treasury Bonds: Users can stake their tokens in exchange for treasury bonds, which accumulate interest over time.
- Blacklist Functionality: Certain addresses can be blacklisted from staking or claiming rewards, managed by the administrator.
- Interest Rate on Staked Bonds: Interest is calculated on the staked bonds based on a basis point system, allowing flexible interest rate changes by governance.

## Features
- Interest Rate Control: Adjust the interest rate for staked treasury bonds.
- Money Supply Control: Increase the money supply (minting new tokens) by the governance role.
- Blacklist Addresses: Admins can blacklist specific addresses, preventing them from participating in staking.
- Staking and Rewards: Users can stake their tokens as treasury bonds and claim rewards based on the time staked.
- Pause/Unpause Functionality: Admins can pause or unpause the contract, freezing token transfers when paused.
- Burnable Token: Tokens can be burned to reduce the total supply.


# Getting Started
## Prerequisites
Make sure you have the following installed on your machine:

- Node.js (>=16.0.0)
- npm (Node Package Manager)
- Hardhat (for smart contract development and testing)

## Installation
Clone this repository:

```bash
git clone https://github.com/TotalingArc/cbdc-smart-contract.git
cd cbdc-smart-contract
```

Install dependencies:

```bash
npm install
```
## Compile the smart contract:

``` bash
npx hardhat compile
```
## Deploying the Contract
To deploy the smart contract on your chosen network, use the following command:

Update the network configuration and deployment script in scripts/deploy.js.

## Deploy the contract:

```bash
npx hardhat run scripts/deploy.js --network <network_name>
```

Make sure to replace <network_name> with the actual network you're deploying to (e.g., sepolia, mainnet, localhost).

# Testing
The project comes with a set of unit tests to ensure the contract behaves as expected. 

## Install Testing Libraries
Before running the tests, ensure that you have installed the necessary testing libraries:

```bash
npm install --save-dev chai @nomiclabs/hardhat-ethers ethers
```

## Run test

```bash
npx hardhat test
```

