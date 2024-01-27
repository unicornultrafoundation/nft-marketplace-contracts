// scripts/upgrade_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const RoyaltiesRegistry = await ethers.getContractFactory('RoyaltiesRegistry');
  console.log('Upgrading RoyaltiesRegistry...');
  await upgrades.upgradeProxy('0x6DA88C2e364AF1112e62872b5b69A16daeb38446', RoyaltiesRegistry);
  console.log('RoyaltiesRegistry upgraded');
}

main();