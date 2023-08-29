import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

import "@typechain/hardhat";
import "hardhat-gas-reporter";

require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ETHERSCAN_KEY = process.env.ETHERSCAN_KEY || "";

// WBTC deployed to: 0xc27253078Ef94226437f46f3089EbA0e9cc5C89E
// WETH deployed to: 0x49E6Bb60E4eC4CEc4Ae7CB5BacfDF69ba661e2E7
// DemoVault deployed to: 0xf93B92f7D53849Ade353EA328cFdf8f27ad1e82A
// Deposited 1000000000000000000000000 tokens of each kind into DemoVault
// dETF deployed to: 0x7C585B7E9D3364dC14CDfE545Bf9A333d5dBd1D6



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
    apiKey: ETHERSCAN_KEY,
  },
  gasReporter: {
    enabled: true,
    excludeContracts: ["test*", "@openzeppelin*"],
  },
};

export default config;