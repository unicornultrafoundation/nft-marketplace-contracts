// scripts/upgrade_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const FeeDistributor = await ethers.getContractFactory('FeeDistributor');
  console.log('Upgrading FeeDistributor...');
  await upgrades.upgradeProxy('0xF8a69EB25D0cd84E2B0037b4B5957EB8f832E581', FeeDistributor);
  console.log('FeeDistributor upgraded');
}

main();