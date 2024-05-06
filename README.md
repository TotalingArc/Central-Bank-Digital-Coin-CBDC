# Central Bank Digital Coin (CBDC) Smart Contract

This Solidity smart contract implements a Central Bank Digital Coin (CBDC), a token representing digital fiat currency issued by a central bank. The CBDC contract inherits functionalities from various OpenZeppelin contracts such as ERC20, ERC20Burnable, Pausable, and AccessControl.

## Features

- **Token Management**: CBDC tokens can be minted, burned, and transferred.
- **Pausing**: The contract owner can pause and unpause token transfers.
- **Access Control**: Different roles (ADMIN_ROLE and GOVERNANCE_ROLE) control various aspects of the contract's functionalities.
- **Interest Rate**: The contract allows updating the interest rate expressed in basis points (0.01% increments).
- **Inflation**: The contract allows increasing the money supply through inflation.
- **Blacklisting**: Certain addresses can be blacklisted to prevent them from claiming rewards.
- **Treasury Bonds**: Users can stake CBDC tokens as treasury bonds and claim rewards based on the interest rate.

## Roles

- **ADMIN_ROLE**: The admin role has permissions to update the blacklist and pause/unpause the contract.
- **GOVERNANCE_ROLE**: The governance role has permissions to update the interest rate and increase the money supply.

## Constructor

The constructor initializes the contract with an initial governance address and an initial supply of CBDC tokens.

## Functions

- **updateInterestRate**: Update the interest rate (GOVERNANCE_ROLE).
- **increaseMoneySupply**: Increase the money supply through inflation (GOVERNANCE_ROLE).
- **updateBlacklist**: Update the blacklist to prevent certain addresses from claiming rewards (ADMIN_ROLE).
- **stakeTreasuryBonds**: Stake CBDC tokens as treasury bonds.
- **unstakeTreasuryBonds**: Unstake previously staked CBDC tokens.
- **claimTreasuryBonds**: Claim rewards for staked CBDC tokens, subject to interest rate and blacklist checks.
- **pause**: Pause token transfers (ADMIN_ROLE).
- **unpause**: Unpause token transfers (ADMIN_ROLE).
- **isBlacklisted**: Check if an address is blacklisted.

## Events

- **InterestRateUpdated**: Emitted when the interest rate is updated.
- **IncreaseMoneySupply**: Emitted when the money supply is increased through inflation.
- **BlacklistUpdated**: Emitted when the blacklist is updated for an address.
- **TreasuryBondsStaked**: Emitted when CBDC tokens are staked as treasury bonds.
- **TreasuryBondsUnstaked**: Emitted when previously staked CBDC tokens are unstaked.
- **TreasuryBondsClaimed**: Emitted when rewards are claimed for staked CBDC tokens.

## License

This CBDC smart contract is licensed under the [MIT License](LICENSE).
