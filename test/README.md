# Real Estate Investment Smart Contract Test

This test file contains test cases for the `RealEstateInvestment` smart contract. It uses the Chai assertion library and the BN.js library for working with Big Numbers.

## Test Setup

- `contractDeployer`: The account address of the contract deployer.
- `properyLister_01`: The account address of the first property lister.
- `investor_01`, `investor_02`, `investor_03`, `investor_04`: Account addresses of the investors.
- `properyLister_02`: The account address of the second property lister.
- `tenant_01`, `tenant_02`: Account addresses of the tenants.

## Test Cases

### Contract Deployment

- **Should Deploy RealEstateInvestment Smart Contract**: Verifies that the `RealEstateInvestment` smart contract is deployed successfully.

### Raise Funding

- **List First Property**: Tests the listing of a property by the property lister. Verifies the property details and the associated token contract.

### Invest in Property

- **First Investor invested successfully**: Tests an investor's successful investment in the property. Verifies the increase in the total funds raised.

- **Claim token before enddate - throw error**: Tests the claim token function before the investment period ends. Expects an error to be thrown.

- **Waiting for investment to be completed**: Adds a delay of 1 second to simulate the investment completion period.

- **Claim token after enddate - minimum investment completed**: Tests the claim token function after the investment period ends. Verifies the successful token claim and token balances of the investor and the base contract.

### Deposit & Withdrawal

- **Deposit Rent**: Tests the deposit rent function by a tenant. Verifies the decrease in the token contract's Ether balance.

- **Withdraw Dividend**: Tests the withdrawal of dividends by an investor. Verifies the decrease in the token contract's Ether balance and the increase in the investor's Ether balance.

## Usage

To run the tests, follow these steps:

1. Deploy the `RealEstateInvestment` smart contract to an Ethereum network.
2. Update the account addresses in the test file according to your setup.
3. Run the test file using a testing framework like Truffle or Hardhat.

Please note that this test file assumes the usage of the Chai assertion library and the BN.js library. Make sure to install these dependencies before running the tests.

**Note**: This README is generated based on the provided test code. Please review and modify it as necessary.
