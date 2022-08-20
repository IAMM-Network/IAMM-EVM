const hre = require("hardhat");

async function main() {
  const IssuerAddress = "0x0000000000000000000000000000000000000000";

  const ClaimVerifierABI = await hre.ethers.getContractFactory("ClaimVerifier");
  const claimVerifier = await ClaimVerifierABI.deploy();

  await claimVerifier.deployed(IssuerAddress);

  console.log("Claim Issuer Deploy:", claimVerifier.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
