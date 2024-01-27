require('dotenv').config();
const ethers = require('ethers');

const abiERC721NFTMarketplace = require('../abis/ERC721NFTMarketplace.json');
const abiERC1155NFTMarketplace = require('../abis/ERC1155NFTMarketplace.json');
const abiFeeDistributor = require('../abis/FeeDistributor.json');
const abiRoyaltiesRegistry = require('../abis/RoyaltiesRegistry.json');
const abiERC721U2U = require('../abis/ERC721U2U.json');
const abiERC20 = require('../abis/ERC20.json');

const addressERC721NFTMarketplace = '0x79d1BDbae020F4E2DC35148b2602bCd6621835AA';
const addressERC1155NFTMarketplace = '0xf013f1Fc60BB1c47F7005554F4727ecFAbda4fc7';
const addressRoyaltiesRegistry = '0x263DaF339e4798c9adC16950B36b7381FCdB2672';
const addressFeeDistributor = '0x480E42EfDB31C4E872e6108103E992Dd00EB96F2';

const addressNFT721 = '0xbcc7FB8d1b4aD76ddD8cB9836655382050fB319c';
const tokenId = '1';
const quoteToken = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';
const price = '5000';
const fingerprint = '0x0000000000000000000000000000000000000000000000000000000000000000';

const addressCollectionOwner = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';
const addressAccount3 = '0x34f2Cecf1d7cf55A8D2B392Ba9EAb0770304478F';
const addressAccount4 = '0xda874Bf03fA9C3B4065EFa14AfBc3bd97582800b';
const addressAccount5 = '0xf11a15b0d71a37B1D3A1eD6A6d1EfC818140D911';
const addressAccount6 = '0xdEc03F9919c086f5B6cE18fD622c2c0D9eCBEF31';
const addressAccount7 = '0x25AbEbC5A3cAF856512440E52124E38a88aC5AE6';

const royaltiesByToken = [];

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

  const contractERC721NFTMarketplaceSigner1 = new ethers.Contract(addressERC721NFTMarketplace, abiERC721NFTMarketplace, signer1);
  const txSetFeeDistributor721Marketplace = await contractERC721NFTMarketplaceSigner1.setFeeDistributor(addressFeeDistributor);
  await txSetFeeDistributor721Marketplace.wait();

  const contractRoyaltiesRegistrySigner1 = new ethers.Contract(addressRoyaltiesRegistry, abiRoyaltiesRegistry, signer1);
  const txInitializeRoyaltiesByToken = await contractRoyaltiesRegistrySigner1.initializeRoyaltiesByToken(addressNFT721);
  await txInitializeRoyaltiesByToken.wait();

  const contractNFT721Signer7 = new ethers.Contract(addressNFT721, abiERC721U2U, signer7);
  const txApproveNFT721 = await contractNFT721Signer7.approve(addressERC721NFTMarketplace, tokenId);
  await txApproveNFT721.wait();

  const contractERC721NFTMarketplaceSigner7 = new ethers.Contract(addressERC721NFTMarketplace, abiERC721NFTMarketplace, signer7);
  const txCreateAsk721Marketplace = await contractERC721NFTMarketplaceSigner7.createAsk(addressNFT721, tokenId, quoteToken, price);
  await txCreateAsk721Marketplace.wait();

  const contractERC20Signer6 = new ethers.Contract(quoteToken, abiERC20, signer6);
  const txApproveERC20Signer6 = await contractERC20Signer6.approve(addressERC721NFTMarketplace, price);
  await txApproveERC20Signer6.wait();

  const contractERC721NFTMarketplaceSigner6 = new ethers.Contract(addressERC721NFTMarketplace, abiERC721NFTMarketplace, signer6);
  const txBuy721Marketplace = await contractERC721NFTMarketplaceSigner6.buy(addressNFT721, tokenId, quoteToken, price, fingerprint);
  await txBuy721Marketplace.wait();
};

buy3();