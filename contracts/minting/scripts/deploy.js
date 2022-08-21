// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {


  // await lock.deployed();
  const RentableIAMM = await hre.ethers.getContractFactory("RentableIAMM");
  const rentableIAMM = await RentableIAMM.deploy("GameItemIAMM","GII");

  await rentableIAMM.deployed();

  console.log(
    `Deployed Rentable, address: ${rentableIAMM.address} transaction to ${rentableIAMM.deployTransaction.hash}`
  );

  let maxSupply = "100000000000000000000000000";

  const MetaToken = await hre.ethers.getContractFactory("MetaToken");
  const metaToken = await MetaToken.deploy("MetaToken","MTIAAM", maxSupply.toLocaleString('fullwide', {useGrouping:false}));

  await metaToken.deployed();

  console.log(
    `Deployed MetaToken, address: ${metaToken.address} transaction to ${metaToken.deployTransaction.hash}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
