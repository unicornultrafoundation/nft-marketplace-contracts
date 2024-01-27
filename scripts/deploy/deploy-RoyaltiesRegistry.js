// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const RoyaltiesRegistry = await ethers.getContractFactory("RoyaltiesRegistry");
  const royaltiesRegistry = await upgrades.deployProxy(RoyaltiesRegistry);
  await royaltiesRegistry.waitForDeployment();
  const addressRoyaltiesRegistry = await royaltiesRegistry.getAddress();

  console.log("royaltiesRegistry address:", addressRoyaltiesRegistry);
}

main();