require('dotenv').config();
const ethers = require('ethers');

const {
  ADDRESS_ERC721_NFT_MARKETPLACE,
  ADDRESS_ERC721U2U,
} = require('../../constants');

const abiERC721NFTMarketplace = require('../../../abis/ERC721NFTMarketplace.json');
const abiERC721U2U = require('../../../abis/ERC721U2U.json');
const abiERC20 = require('../../../abis/ERC20.json');

const tokenId = '56251463693617246046355321745876076992767688222070539471992322248019722371072';
const quoteToken = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';
const price = '2000';
const totalPrice = '2025'

const addressCollectionOwner = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';
const addressAccount3 = '0x34f2Cecf1d7cf55A8D2B392Ba9EAb0770304478F';
const addressAccount4 = '0xda874Bf03fA9C3B4065EFa14AfBc3bd97582800b';
const addressAccount5 = '0xf11a15b0d71a37B1D3A1eD6A6d1EfC818140D911';
const addressAccount6 = '0xdEc03F9919c086f5B6cE18fD622c2c0D9eCBEF31';
const addressAccount7 = '0x25AbEbC5A3cAF856512440E52124E38a88aC5AE6';

const privateKeys = [
  process.env.PRIVATE_KEY_1,
  process.env.PRIVATE_KEY_2,
  process.env.PRIVATE_KEY_3,
  process.env.PRIVATE_KEY_4,
  process.env.PRIVATE_KEY_5,
  process.env.PRIVATE_KEY_6,
  process.env.PRIVATE_KEY_7
];
const main = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer1 = new ethers.Wallet(privateKeys[0], provider);
  const signer2 = new ethers.Wallet(privateKeys[1], provider);
  const signer3 = new ethers.Wallet(privateKeys[2], provider);
  const signer4 = new ethers.Wallet(privateKeys[3], provider);
  const signer5 = new ethers.Wallet(privateKeys[4], provider);

  const contractERC20Signer3 = new ethers.Contract(quoteToken, abiERC20, signer3);
  const txApproveERC20Signer3 = await contractERC20Signer3.approve(ADDRESS_ERC721_NFT_MARKETPLACE, totalPrice);
  await txApproveERC20Signer3.wait();

  const contractERC721NFTMarketplaceSigner3 = new ethers.Contract(ADDRESS_ERC721_NFT_MARKETPLACE, abiERC721NFTMarketplace, signer3);
  const txBuy721Marketplace = await contractERC721NFTMarketplaceSigner3.createBid(ADDRESS_ERC721U2U, tokenId, quoteToken, price);
  await txBuy721Marketplace.wait();

  const contractNFT721Signer5 = new ethers.Contract(ADDRESS_ERC721U2U, abiERC721U2U, signer5);
  const txApproveNFT721 = await contractNFT721Signer5.approve(ADDRESS_ERC721_NFT_MARKETPLACE, tokenId);
  await txApproveNFT721.wait();

  const contractERC721NFTMarketplaceSigner5 = new ethers.Contract(ADDRESS_ERC721_NFT_MARKETPLACE, abiERC721NFTMarketplace, signer5);
  const txCreateAsk721Marketplace = await contractERC721NFTMarketplaceSigner5.acceptBid(ADDRESS_ERC721U2U, tokenId, addressAccount3, quoteToken);
  await txCreateAsk721Marketplace.wait();
};

main();