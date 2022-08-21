require("@nomicfoundation/hardhat-toolbox");

const ALCHEMY_API_KEY = "vW3OrumvOZK8_CwAIQNEB8Uo0Pljy7h5";

const POLYGON_PRIVATE_KEY = "0x4413ba0c12f9b5bda0f177581369ae3f0bebd8a2451cbb009fd874b4f6eb7bad";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.7",
  networks: {
    polygonMumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [POLYGON_PRIVATE_KEY]
    }
  }
};
