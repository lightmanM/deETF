import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";

require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY || "";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    sepolia: {
        url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
        accounts: [PRIVATE_KEY],
    }
  },
  solidity: {
    version: "0.8.19",
    settings: { optimizer: { enabled: true, runs: 12000 } },
  },
  etherscan: {
    // apiKey: {
    // goerli: ETHERSCAN_KEY
    // }
  },
  gasReporter: {
    enabled: true,
    excludeContracts: ["test*", "@openzeppelin*"],
  },
};

export default config;