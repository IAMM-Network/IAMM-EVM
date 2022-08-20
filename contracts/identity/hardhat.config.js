require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");
require("@nomicfoundation/hardhat-chai-matchers");

const fs = require("fs");
const privateKey = fs.readFileSync(".secret").toString().trim();

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/k0Va33YvhIFBGdZCZlP8pYi2ffYybtxA",
      accounts: [privateKey]
    },
    polygon: {
      url: "https://polygon-rpc.com",
      accounts: [privateKey]
    }
  },
  solidity: "0.8.7"
};
