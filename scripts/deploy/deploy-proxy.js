// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  // const feeReceipient = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';
  const feeReceipient = '0x46D45Fc0A462FCc234e8f410FdDeFF02142fC029';
  const weth = '0x79538ce1712498fD1b9A9861E62acB257d7506fC';

  const ERC721NFTMarketplace = await ethers.getContractFactory("ERC721NFTMarketplace");
  const erc721NFTMarketplace = await upgrades.deployProxy(
    ERC721NFTMarketplace,
    ['0x0000000000000000000000000000000000000000', weth]
  );
  await erc721NFTMarketplace.waitForDeployment();
  const addressERC721NFTMarketplace = await erc721NFTMarketplace.getAddress();

  const ERC1155NFTMarketplace = await ethers.getContractFactory("ERC1155NFTMarketplace");
  const erc1155NFTMarketplace = await upgrades.deployProxy(
    ERC1155NFTMarketplace,
    ['0x0000000000000000000000000000000000000000', weth]
  );
  await erc1155NFTMarketplace.waitForDeployment();
  const addressERC1155NFTMarketplace = await erc1155NFTMarketplace.getAddress();

  const RoyaltiesRegistry = await ethers.getContractFactory("RoyaltiesRegistry");
  const royaltiesRegistry = await upgrades.deployProxy(RoyaltiesRegistry);
  await royaltiesRegistry.waitForDeployment();
  const addressRoyaltiesRegistry = await royaltiesRegistry.getAddress();

  const FeeDistributor = await ethers.getContractFactory("FeeDistributor");
  const feeDistributor = await upgrades.deployProxy(
    FeeDistributor,
    [
      addressERC721NFTMarketplace,
      addressERC1155NFTMarketplace,
      addressRoyaltiesRegistry,
      feeReceipient,
      250,
      5000
    ]
  );
  await feeDistributor.waitForDeployment();

  console.log("erc721NFTMarketplace address:", addressERC721NFTMarketplace);
  console.log("erc1155NFTMarketplace address:", addressERC1155NFTMarketplace);
  console.log("royaltiesRegistry address:", await royaltiesRegistry.getAddress());
  console.log("feeDistributor address:", await feeDistributor.getAddress());
}

main();