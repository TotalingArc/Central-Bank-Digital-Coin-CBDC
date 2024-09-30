#Central Bank Digital Coin (CBDC)

##Overview
This smart contract implements a Central Bank Digital Coin (CBDC) with the following key features:

- ERC20 Token Standard: The token follows the ERC20 standard, with additional burn and pause functionalities.
- Role-based Access Control: Administrators and governance entities can control actions such as interest rate adjustments, money supply inflation, and blacklisting of accounts.
- Staking of Treasury Bonds: Users can stake their tokens in exchange for treasury bonds, which accumulate interest over time.
- Blacklist Functionality: Certain addresses can be blacklisted from staking or claiming rewards, managed by the administrator.
- Interest Rate on Staked Bonds: Interest is calculated on the staked bonds based on a basis point system, allowing flexible interest rate changes by governance.
