require('dotenv').config();
const ethers = require('ethers');

const abiUpgrade = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "arg0",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "arg1",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "arg2",
        "type": "bytes"
      }
    ],
    "name": "upgradeAndCall",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
]

const address = '0x884a18594511Af6eedb5c0786bf0afc1792B48ff';

const privateKeys = [
  process.env.PRIVATE_KEY_1,
  process.env.PRIVATE_KEY_2,
  process.env.PRIVATE_KEY_3,
  process.env.PRIVATE_KEY_4,
  process.env.PRIVATE_KEY_5,
  process.env.PRIVATE_KEY_6,
  process.env.PRIVATE_KEY_7
];
const buy1 = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer1 = new ethers.Wallet(privateKeys[0], provider);
  const contract = new ethers.Contract(address, abiUpgrade, signer1);
  const tx = await contract.upgradeAndCall('0x2eeb48d7cb2bff62268883970efd6f7c0136e5f0', '0xA638ec9D7E1C995187A1cF887e08B661d95643E5', '0x');
  await tx.wait();
};

buy1();