async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  const feeReceipient = '0x7c5d333f2ce3e919E5B17a237f223D6bAa35a345';

  const erc721NFTMarketplace = await ethers.deployContract(
    "ERC721NFTMarketplace",
    ['0x0000000000000000000000000000000000000000', '0x79538ce1712498fD1b9A9861E62acB257d7506fC']
  );
  const addressERC721NFTMarketplace = await erc721NFTMarketplace.getAddress();
  const erc1155NFTMarketplace = await ethers.deployContract(
    "ERC1155NFTMarketplace",
    ['0x0000000000000000000000000000000000000000', '0x79538ce1712498fD1b9A9861E62acB257d7506fC']
  );
  const addressERC1155NFTMarketplace = await erc1155NFTMarketplace.getAddress();
  
  // const royaltiesRegistry = await ethers.deployContract("RoyaltiesRegistry");
  // const addressRoyaltiesRegistry = await royaltiesRegistry.getAddress();

  // const feeDistributor = await ethers.deployContract(
  //   "FeeDistributor",
  //   [
  //     addressERC721NFTMarketplace,
  //     addressERC1155NFTMarketplace,
  //     addressRoyaltiesRegistry,
  //     feeReceipient,
  //     250
  //   ]
  // );
  console.log("erc721NFTMarketplace address:", addressERC721NFTMarketplace);
  console.log("erc1155NFTMarketplace address:", addressERC1155NFTMarketplace);
  // console.log("royaltiesRegistry address:", await royaltiesRegistry.getAddress());
  // console.log("feeDistributor address:", await feeDistributor.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });