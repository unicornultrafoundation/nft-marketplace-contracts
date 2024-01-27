require('dotenv').config();
const ethers = require('ethers');

const abiERC721NFTMarketplace = require('../abis/ERC721NFTMarketplace.json');
const abiERC1155NFTMarketplace = require('../abis/ERC1155NFTMarketplace.json');
const abiFeeDistributor = require('../abis/FeeDistributor.json');
const abiRoyaltiesRegistry = require('../abis/RoyaltiesRegistry.json');
const abiERC721U2U = require('../abis/ERC721U2U.json');
const abiERC20 = require('../abis/ERC20.json');

const addressERC721NFTMarketplace = '0xD77c7119beDAcE79DB1dEf9d95A34192c44Bb65F';
const addressERC1155NFTMarketplace = '0xaADfeE64CC9b8A036Af50a0A669e493A7314eE83';
const addressRoyaltiesRegistry = '0xc00BaBe750a75B4f320077034c62a4e2cF51f1DB';
const addressFeeDistributor = '0x3502d8064A13fea50fCE34355C1A41E7a9D73CE7';

const addressNFT721 = '0xe1c5955e593a4ddf5E822e1638205E6980F36E2c';
const tokenId = '17039333484408349885912678942470975577154994630701829741785943859982191558657';
const quoteToken = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';
const priceSell = '3000';
const priceBuy = '3038'
const fingerprint = '0x0000000000000000000000000000000000000000000000000000000000000000';

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
const buy3 = async () => {
  const provider = new ethers.JsonRpcProvider('https://rpc-nebulas-testnet.uniultra.xyz');
  const signer1 = new ethers.Wallet(privateKeys[0], provider);
  const signer2 = new ethers.Wallet(privateKeys[1], provider);
  const signer3 = new ethers.Wallet(privateKeys[2], provider);
  const signer4 = new ethers.Wallet(privateKeys[3], provider);
  const signer5 = new ethers.Wallet(privateKeys[4], provider);
  const signer6 = new ethers.Wallet(privateKeys[5], provider);
  const signer7 = new ethers.Wallet(privateKeys[6], provider);

  const contractNFT721Signer7 = new ethers.Contract(addressNFT721, abiERC721U2U, signer7);
  const txApproveNFT721 = await contractNFT721Signer7.approve(addressERC721NFTMarketplace, tokenId);
  await txApproveNFT721.wait();

  const contractERC721NFTMarketplaceSigner7 = new ethers.Contract(addressERC721NFTMarketplace, abiERC721NFTMarketplace, signer7);
  const txCreateAsk721Marketplace = await contractERC721NFTMarketplaceSigner7.createAsk(addressNFT721, tokenId, quoteToken, priceSell);
  await txCreateAsk721Marketplace.wait();

  const contractERC20Signer6 = new ethers.Contract(quoteToken, abiERC20, signer6);
  const txApproveERC20Signer6 = await contractERC20Signer6.approve(addressERC721NFTMarketplace, priceBuy);
  await txApproveERC20Signer6.wait();

  const contractERC721NFTMarketplaceSigner6 = new ethers.Contract(addressERC721NFTMarketplace, abiERC721NFTMarketplace, signer6);
  const txBuy721Marketplace = await contractERC721NFTMarketplaceSigner6.buy(addressNFT721, tokenId, quoteToken, priceBuy, fingerprint);
  await txBuy721Marketplace.wait();
};

buy3();