require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.7.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  // paths: {
  //   sources: "./contracts/RoyaltiesRegistry.sol"
  // },
  networks: {
    u2uTestnet: {
      url: "https://rpc-nebulas-testnet.uniultra.xyz",
      accounts: [process.env.PRIVATE_KEY_1],
      gas: 8000000
    }
  },
  etherscan: {
    apiKey: {
      u2uTestnet: "hi"
    },
    customChains: [
      {
        network: "u2uTestnet",
        chainId: 2484,
        urls: {
          apiURL: "https://testnet.u2uscan.xyz/api",
          browserURL: "https://testnet.u2uscan.xyz/"
        }
      }
    ]
  },
};
