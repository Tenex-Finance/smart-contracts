import * as dotenv from "dotenv";
import * as tdly from "@tenderly/hardhat-tenderly"; //Cannot find module '@tenderly/hardhat-tenderly' or its corresponding type declarations.
//import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-verify"; // ✅ new verification plugin

dotenv.config();

export default {
  defaultNetwork: "bsc",
  networks: {
    hardhat: {},
    bsc: {
      url: process.env.BSC_RPC_URL,
      accounts: [process.env.PRIVATE_KEY_DEPLOY],
      gasPrice: 1000000
    },
  },
  etherscan: {
    apiKey: process.env.BSC_SCAN_API_KEY, // ✅ Etherscan V2 key
    customChains: [
      {
        network: "bsc",
        chainId: 56,
        urls: {
          apiURL: process.env.BSC_ETHERSCAN_VERIFIER_URL,
          browserURL: "https://bscscan.com"
        }
      }
    ]
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  typechain: {
    outDir: "artifacts/types",
    target: "ethers-v5",
  },
};
