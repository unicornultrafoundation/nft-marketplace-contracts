require('dotenv').config();
const ethers = require('ethers');
const {
  ADDRESS_ERC1155_NFT_MARKETPLACE,
  ADDRESS_ERC1155U2U,
} = require('../../constants');

const abiERC1155NFTMarketplace = require('../../../abis/ERC1155NFTMarketplace.json');
const abiERC1155U2U = require('../../../abis/ERC1155U2U.json');
const abiERC20 = require('../../../abis/ERC20.json');

// Params offer
const tokenId = '56251463693617246046355321745876076992767688222070539471992322248019722371072';
const quantityBuy = '2';
const quoteToken = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';
const priceBuyPerUnit = '3000';
const totalPrice = '6076';

// Params accept
const offerId = '26';

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
const buy2 = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer1 = new ethers.Wallet(privateKeys[0], provider);
  const signer2 = new ethers.Wallet(privateKeys[1], provider);
  const signer3 = new ethers.Wallet(privateKeys[2], provider);
  const signer4 = new ethers.Wallet(privateKeys[3], provider);
  const signer5 = new ethers.Wallet(privateKeys[4], provider);

  const contractERC20Signer5 = new ethers.Contract(quoteToken, abiERC20, signer5);
  const txApproveERC20Signer5 = await contractERC20Signer5.approve(ADDRESS_ERC1155_NFT_MARKETPLACE, totalPrice);
  await txApproveERC20Signer5.wait();

  const contractERC1155NFTMarketplaceSigner5 = new ethers.Contract(ADDRESS_ERC1155_NFT_MARKETPLACE, abiERC1155NFTMarketplace, signer5);
  const txBuy1155Marketplace = await contractERC1155NFTMarketplaceSigner5.createOffer(ADDRESS_ERC1155U2U, tokenId, quantityBuy, quoteToken, priceBuyPerUnit);
  await txBuy1155Marketplace.wait();

  const contractERC1155NFTMarketplaceSigner3 = new ethers.Contract(ADDRESS_ERC1155_NFT_MARKETPLACE, abiERC1155NFTMarketplace, signer3);
  const txAcceptOffer = await contractERC1155NFTMarketplaceSigner3.acceptOffer(offerId, quantityBuy);
  await txAcceptOffer.wait();
};

buy2();