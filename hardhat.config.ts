import * as dotenv from "dotenv";
import * as tdly from "@tenderly/hardhat-tenderly";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";

dotenv.config();
tdly.setup({ automaticVerifications: false });

export default {
  defaultNetwork: "tenderly",
  networks: {
    hardhat: {},
    blastSepolia: {
      url: "https://blast-sepolia.infura.io/v3/9825e07b04b544679b88dc78bdf014e8",
      accounts: [`${process.env.PRIVATE_KEY_DEPLOY}`],
      gasPrice : 1000000

    },
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
  tenderly: {
    username: "velodrome-finance",
    project: "v2",
    privateVerification: false,
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
