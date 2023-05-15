# Real Estate Investment Contract

This Solidity contract represents a real estate investment platform that allows users to invest in properties using Ether and receive corresponding tokens. The contract is built on the Ethereum blockchain and uses the ERC20 token standard.

## Contract Details

- **License**: MIT
- **Solidity Version**: 0.4.22 to 0.9.0

## Prerequisites

This contract has external dependencies on other contracts. Please make sure to import the following contracts before deploying this contract:

- OpenZeppelin `Counters` library
- OpenZeppelin `ReentrancyGuard` library
- `RealEstateToken` contract (located in a separate file)

## Contract Functionality

### Structs

1. **Property**: Represents a real estate property and its associated information, including the token, investment limits, owner, total funds raised, and ICO cutoff period.
2. **InvestorDetail**: Contains details about an investor, including their address and the amount of Ether they have invested.

### Events

1. **DepositRent**: Triggered when an investor deposits rent into the contract.
2. **TokenClaimLog**: Logs token claim events, indicating that tokens have been successfully claimed.
3. **DividendWithdraw**: Triggered when a user withdraws dividends from the contract.

### Storage

1. **properties**: A mapping that stores property details based on their property IDs.
2. **investorDetails**: A mapping that stores investor details (amount invested) for each property ID and investor address.
3. **tokenOwed**: A mapping that stores the amount of tokens owed to each investor for each property ID.

### Modifiers

1. **PropertyExist**: Checks if a property with the given property ID exists.

### Functions

1. **listPropertyByOwner**: Allows the owner to list a new property for investment. This function deploys a new instance of the `RealEstateToken` contract, reserves tokens for the owner and investors, and stores property details.
2. **setCounter**: Internal function that increments the property ID counter.
3. **getCounter**: Internal function that returns the current property ID counter.
4. **isPropertyExist**: Internal function that checks if a property with the given property ID exists.
5. **investInProperty**: Allows investors to invest Ether into a property. The invested Ether is converted into tokens and credited to the investor's address.
6. **claimToken**: Allows investors to claim their tokens after the ICO cutoff period has passed. If the total funds raised meet the minimum investment threshold, the tokens are transferred to the investor. Otherwise, the invested Ether is returned.
7. **depositRent**: Allows investors to deposit rent into the contract.
8. **withDrawDividend**: Allows investors to withdraw dividends from the contract.

## Usage

To use this contract, follow these steps:

1. Deploy the contract to an Ethereum network.
2. Import the required dependencies: `Counters`, `ReentrancyGuard`, and `RealEstateToken`.
3. Call the `listPropertyByOwner` function to list a new property, providing the necessary parameters.
4. Investors can then call the `investInProperty` function to invest Ether into the listed property.
5. After the ICO cutoff period has passed, investors can claim their tokens by calling the `claimToken` function.
6. Investors can also deposit rent into the contract using the `depositRent` function.
7. Dividends can be withdrawn by investors using the `withDrawDividend` function.

Please note that this contract assumes a 1:1 ratio between Ether and tokens for simplicity. Further modifications may be required to suit your specific needs.



# Real Estate Token Contract

This Solidity contract represents a token contract for real estate investments. It extends the ERC20 standard token contract from the OpenZeppelin library.

## Contract Details

- **License**: MIT
- **Solidity Version**: 0.4.22 to 0.9.0

## Contract Functionality

### Storage

1. **dividendPerToken**: The amount of dividend per token that has been distributed.
2. **dividendBalanceOf**: A mapping that stores the dividend balance for each token holder.
3. **dividendCredited**: A mapping that tracks the last credited dividend for each token holder.
4. **baseContract**: The address of the authorized base contract.

### Events

### Modifiers

1. **onlyBaseContract**: Restricts access to the authorized base contract.

### Functions

1. **isContract**: Internal function to check if an address is a contract.
2. **_beforeTokenTransfer**: Internal function called before token transfers. Updates dividend balances for the sender and receiver.
3. **receive**: Fallback function to receive Ether.
4. **fallback**: Fallback function to receive Ether.
5. **constructor**: Initializes the token contract with a name, symbol, and total token supply. Mints the initial token supply and assigns it to the contract deployer.
6. **depositDividend**: Allows the base contract to deposit dividends into the contract. Dividends are distributed proportionally to token holders.
7. **updateDividend**: Internal function to update the dividend balance for a token holder.
8. **withdraw**: Allows token holders to withdraw their accumulated dividends.

## Usage

To use this contract, follow these steps:

1. Deploy the contract to an Ethereum network.
2. Set the `baseContract` address to the address of the authorized base contract.
3. Call the `depositDividend` function from the base contract to deposit dividends into the contract. Dividends will be distributed proportionally to token holders.
4. Token holders can call the `withdraw` function to withdraw their accumulated dividends.

Please note that this contract assumes the usage of the ERC20 token standard and integrates with a base contract to deposit dividends. Additional functionality and modifications may be required to suit your specific requirements.

**Note**: This README is generated based on the provided contract code. Please review and modify it as necessary.
