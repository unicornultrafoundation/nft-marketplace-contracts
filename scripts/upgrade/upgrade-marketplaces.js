// scripts/upgrade_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const ERC721NFTMarketplace = await ethers.getContractFactory('ERC721NFTMarketplace');
  console.log('Upgrading ERC721NFTMarketplace...');
  // await upgrades.forceImport('0x77700AFc1183E520F6ce28e5EE95411Cc88CF36B', ERC721NFTMarketplace, { kind: 'transparent' });
  await upgrades.upgradeProxy('0x77700AFc1183E520F6ce28e5EE95411Cc88CF36B', ERC721NFTMarketplace);
  console.log('ERC721NFTMarketplace upgraded');

  // const ERC1155NFTMarketplace = await ethers.getContractFactory('ERC1155NFTMarketplace');
  // console.log('Upgrading ERC1155NFTMarketplace...');
  // // await upgrades.forceImport('0x46948C71e0b09DddDC8E7fEED92332Dd5b19b5fA', ERC1155NFTMarketplace, { kind: 'transparent' });
  // await upgrades.upgradeProxy('0x46948C71e0b09DddDC8E7fEED92332Dd5b19b5fA', ERC1155NFTMarketplace);
  // console.log('ERC1155NFTMarketplace upgraded');
}

main();