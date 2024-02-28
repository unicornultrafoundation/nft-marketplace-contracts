# U2U Marketplace Smart Contracts Repository

This repository contains smart contracts used for the [U2U NFT marketplace](https://u2nft.io/ "Visit U2U NFT Marketplace").

## Table of Contents

- [Introduction](#introduction)
- [Contracts](#contracts)
- [Installation](#installation)

## Introduction

This repository serves as a collection of smart contracts developed for U2U NFT Marketplace. The following features have been implemented in the code:

- Create a sell (ask) order
- Create a buy (bid) order
- Accept a created buy (bid) order
- Buy a created sell (ask) order
- Buy multiple on sale ERC-721 NFTs in 1 transaction (buy batch)

## Contracts

- **Marketplace Contracts: `ERC721NFTMarketplace`, `ERC1155NFTMarketplace`, `ERC721NFTMarketplaceV2`**.
    - `ERC721NFTMarketplace`: allows users to buy and sell ERC-721 NFTs
        - Mainnet: 0xB6D89fFb7B6d00db395cc4b7B8E9b9fD4774184d
        - Testnet: 0x77700afc1183e520f6ce28e5ee95411cc88cf36b
    - `ERC1155NFTMarketplace`: allows users to buy and sell ERC-1155 NFTs
        - Mainnet: 0x9a36F21be9D9895F1cB5A58895F5fF92c016B985
        - Testnet: 0x46948c71e0b09ddddc8e7feed92332dd5b19b5fa
    - `ERC721NFTMarketplaceV2`: not deployed yet
- **`RoyaltiesRegistry`**: is responsible for retrieving royalties information of an NFT or a collection.
    
    - Mainnet: 0x2Ed0dA2fE3703081BdeE5aa69D7a5623be0B5CA0
    - Testnet: 0xDA14d191fbd1B962cbF58E09D4078071b9fdA079

- **`FeeDistributor`**: handles the task of distributing protocol fees, as well as royalties. The protocol fee is currently set at **2.5%** of listing price per successful purchase, and is currently shared equally between seller and buyer. Though this fee can be changed, it is capped at **5%** of the listing price.

    - Mainnet: 0x6ad68ef2aBf88e2048BBe3bfEE795972D2E477E7
    - Testnet: 0xF8a69EB25D0cd84E2B0037b4B5957EB8f832E581

## Installation

To use these contracts locally or in your project, follow these steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/unicornultrafoundation/nft-marketplace-contracts

2. Install packages and dependencies: `npm install`
3. Compile contracts: `npx hardhat compile`
4. Test: `npx hardhat test <scripts/test/script-name.js>`
5. Deploy:
- Testnet: `npx hardhat deploy --network u2uTestnet <scripts/deploy/script-name.js>`
- Mainnet: `npx hardhat deploy --network u2uMainnet <scripts/deploy/script-name.js>`
6. Verify:
- Testnet: `npx hardhat verify --network u2uTestnet <ContractAddress> <ConstructorParams>`
- Mainnet: `npx hardhat verify --network u2uMainnet <ContractAddress> <ConstructorParams>`

## Further development
We are developing a new version of the marketplace, which will allow users to buy and sell in batch, with better gas usage. Stay tuned for upgrades.