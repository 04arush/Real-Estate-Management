# Real Estate Smart Contract

A blockchain-based real estate management system built with Solidity, enabling property transactions, lease agreements, and transparent title management on the Ethereum blockchain.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Structure](#contract-structure)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Security Considerations](#security-considerations)
- [License](#license)
- [Disclaimer](#Disclaimer)

## 🔍 Overview

This smart contract provides a decentralized platform for managing real estate transactions, including property registration, buying/selling, and lease agreements. All transactions are recorded immutably on the blockchain, ensuring transparency and reducing the need for intermediaries.

## ✨ Features

### 1. **Property Transactions**
- Register properties with unique blockchain IDs
- List and unlist properties for sale
- Direct peer-to-peer property purchases
- Automatic ownership transfer
- Transparent price discovery

### 2. **Lease Agreements**
- Create customizable rental agreements
- Automated rent collection
- Security deposit management
- Flexible lease durations
- Lease termination with deposit return

### 3. **Title Management**
- Immutable ownership records
- Transparent ownership history
- Ownership verification
- Query properties by owner
- Secure title transfers

## 📁 Contract Structure

```
real-estate-management/
├── contracts/
│   └── RealEstate.sol          # Main smart contract
├── .gitignore                  # Git ignore file
├── LICENSE.md                  # MIT License
└── README.md                   # This file
```

**Note**: `.states` and `artifacts` folders are excluded via `.gitignore`

## 🚀 Getting Started

### Prerequisites

- [Remix IDE](https://remix.ethereum.org/)
- Or any Solidity development environment (Hardhat, Foundry)
- MetaMask or any Web3 wallet
- Testnet ETH for deployment

### Deployment Options

#### Option 1: Remix IDE

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create a new file `RealEstate.sol`
3. Copy and paste the contract code from `contracts/RealEstate.sol`
4. Select Solidity compiler version `0.8.20` or higher
5. Click "Compile RealEstate.sol"
6. Go to "Deploy & Run Transactions" tab
7. Select environment (JavaScript VM for testing, Injected Provider for testnet/mainnet)
8. Click "Deploy"
9. Save the deployed contract address

#### Option 2: Using Hardhat

```bash
# Install dependencies
npm install --save-dev hardhat

# Compile
npx hardhat compile

# Deploy
npx hardhat run scripts/deploy.js --network <network-name>
```

## 💡 Usage

### Register a Property

```solidity
// Call registerProperty function
registerProperty("123 Main Street, City, State, 12345", 1000000000000000000); // 1 ETH in wei
```

### List Property for Sale

```solidity
// Property owner lists property #1 for 1 ETH
listPropertyForSale(1, 1000000000000000000);
```

### Purchase Property

```solidity
// Buyer purchases property #1 by sending exact price
purchaseProperty{value: 1000000000000000000}(1);
```

### Create Lease Agreement

```solidity
// Landlord creates 12-month lease with 0.1 ETH monthly rent and 0.2 ETH deposit
createLease(
    1,                                  // propertyId
    0x742d35Cc6634C0532925a3b844Bc9e,  // tenant address
    100000000000000000,                 // 0.1 ETH monthly rent
    200000000000000000,                 // 0.2 ETH security deposit
    12                                  // 12 months duration
);
```

### Pay Rent

```solidity
// Tenant pays monthly rent for lease #1
payRent{value: 100000000000000000}(1);
```

### Verify Ownership

```solidity
// Check if an address owns a property
bool isOwner = verifyOwnership(1, 0x742d35Cc6634C0532925a3b844Bc9e);
```

## 🔒 Security Considerations

### Implemented Security Features

✅ **Access Control**: Modifiers ensure only authorized users can execute functions

✅ **Input Validation**: All user inputs are validated

✅ **State Checks**: Prevents invalid state transitions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## ⚠️ Disclaimer

**IMPORTANT**: This smart contract is provided for educational and demonstration purposes. It has not been audited and should not be used in production without:

1. Comprehensive security audit
2. Legal review for regulatory compliance
3. Extensive testing on testnets
4. Insurance and risk mitigation strategies

Real estate laws vary significantly by jurisdiction. Always consult with legal professionals before deploying blockchain-based real estate solutions.
