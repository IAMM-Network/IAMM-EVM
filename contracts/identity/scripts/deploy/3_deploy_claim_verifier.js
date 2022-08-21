const hre = require("hardhat");

async function main() {
  const IssuerAddress = "0xa3681AE14FcAF9e11C826448ABe29b03f5b029f4";

  const ClaimVerifierABI = await hre.ethers.getContractFactory("ClaimVerifier");
  const claimVerifier = await ClaimVerifierABI.deploy(IssuerAddress);

  await claimVerifier.deployed();

  console.log("Claim Issuer Deploy:", claimVerifier.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
