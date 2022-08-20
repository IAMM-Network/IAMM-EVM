const hre = require("hardhat");

async function main() {

  const ClaimHolderABI = await hre.ethers.getContractFactory("ClaimHolder");
  const claimHolder = await ClaimHolderABI.deploy();

  await claimHolder.deployed();

  console.log("Claim Issuer Deploy:", claimHolder.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
