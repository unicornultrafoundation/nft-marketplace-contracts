require('dotenv').config();
const {
  ADDRESS_ERC721_NFT_MARKETPLACE,
  ADDRESS_ERC1155_NFT_MARKETPLACE,
  ADDRESS_FEE_DISTRIBUTOR,
} = require('../constants');
const ethers = require('ethers');

const abiERC721NFTMarketplace = require('../../abis/ERC721NFTMarketplace.json');
const abiERC1155NFTMarketplace = require('../../abis/ERC1155NFTMarketplace.json');
const abiERC721U2U = require('../../abis/ERC721U2U.json');
const abiERC20 = require('../../abis/ERC20.json');

const addressNFT721 = '0xe1c5955e593a4ddf5E822e1638205E6980F36E2c';
const tokenId =
  '98843249452964875383935103550354339048105531692015603491815947519251856752640';
const quoteToken = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';
const priceSell = '2000';
const priceBuy = '2025';
const fingerprint =
  '0x0000000000000000000000000000000000000000000000000000000000000000';

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
  process.env.PRIVATE_KEY_7,
];
const buy1 = async () => {
  const provider = new ethers.JsonRpcProvider(
    'https://rpc-nebulas-testnet.uniultra.xyz'
  );
  const signer1 = new ethers.Wallet(privateKeys[0], provider);
  const signer2 = new ethers.Wallet(privateKeys[1], provider);
  const signer3 = new ethers.Wallet(privateKeys[2], provider);
  const signer4 = new ethers.Wallet(privateKeys[3], provider);
  const signer5 = new ethers.Wallet(privateKeys[4], provider);
  const signer6 = new ethers.Wallet(privateKeys[5], provider);
  const signer7 = new ethers.Wallet(privateKeys[6], provider);

  const contractERC721NFTMarketplaceSigner1 = new ethers.Contract(
    ADDRESS_ERC721_NFT_MARKETPLACE,
    abiERC721NFTMarketplace,
    signer1
  );
  const txSetFeeDistributor721Marketplace =
    await contractERC721NFTMarketplaceSigner1.setFeeDistributor(
      ADDRESS_FEE_DISTRIBUTOR
    );
  await txSetFeeDistributor721Marketplace.wait();

  const contractERC1155NFTMarketplaceSigner1 = new ethers.Contract(
    ADDRESS_ERC1155_NFT_MARKETPLACE,
    abiERC1155NFTMarketplace,
    signer1
  );
  const txSetFeeDistributor1155Marketplace =
    await contractERC1155NFTMarketplaceSigner1.setFeeDistributor(
      ADDRESS_FEE_DISTRIBUTOR
    );
  await txSetFeeDistributor1155Marketplace.wait();

  const contractNFT721Signer3 = new ethers.Contract(
    addressNFT721,
    abiERC721U2U,
    signer3
  );
  const txApproveNFT721 = await contractNFT721Signer3.approve(
    ADDRESS_ERC721_NFT_MARKETPLACE,
    tokenId
  );
  await txApproveNFT721.wait();

  const contractERC721NFTMarketplaceSigner3 = new ethers.Contract(
    ADDRESS_ERC721_NFT_MARKETPLACE,
    abiERC721NFTMarketplace,
    signer3
  );
  const txCreateAsk721Marketplace =
    await contractERC721NFTMarketplaceSigner3.createAsk(
      addressNFT721,
      tokenId,
      quoteToken,
      priceSell
    );
  await txCreateAsk721Marketplace.wait();

  const contractERC20Signer7 = new ethers.Contract(
    quoteToken,
    abiERC20,
    signer7
  );
  const txApproveERC20Signer7 = await contractERC20Signer7.approve(
    ADDRESS_ERC721_NFT_MARKETPLACE,
    priceBuy
  );
  await txApproveERC20Signer7.wait();

  const contractERC721NFTMarketplaceSigner7 = new ethers.Contract(
    ADDRESS_ERC721_NFT_MARKETPLACE,
    abiERC721NFTMarketplace,
    signer7
  );
  const txBuy721Marketplace = await contractERC721NFTMarketplaceSigner7.buy(
    addressNFT721,
    tokenId,
    quoteToken,
    priceBuy,
    fingerprint
  );
  await txBuy721Marketplace.wait();
};

buy1();
