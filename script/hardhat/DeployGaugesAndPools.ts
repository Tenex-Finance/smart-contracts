import { getContractAt } from "./utils/helpers";
import { PoolFactory, Voter } from "../../artifacts/types";
import jsonConstants from "../constants/Bsc.json";
import { join } from "path";
import deployedContracts from "../constants/output/TenexOutput2.json";
import { writeFile } from "fs/promises";

async function main() {
  const factory = await getContractAt<PoolFactory>(
    "PoolFactory",
    deployedContracts.poolFactory
  );
  const voter = await getContractAt<Voter>("Voter", deployedContracts.voter);

  let poolsV2: string[] = [];
  let gaugesPoolsV2: string[] = [];

  // Deploy non-TENEX pools and gauges
  for (var i = 0; i < jsonConstants.poolsV2.length; i++) {
    const { stable, tokenA, tokenB } = jsonConstants.poolsV2[i];
    await factory.functions["createPool(address,address,bool)"](
      tokenA,
      tokenB,
      stable,
      { gasLimit: 5000000 }
    );
    let pool = await factory.functions["getPool(address,address,bool)"](
      tokenA,
      tokenB,
      stable,
      {
        gasLimit: 5000000,
      }
    );
    await voter.createGauge(
      deployedContracts.poolFactory, // PoolFactory (v2)
      pool[0],
      { gasLimit: 5000000 }
    );

    let gauge = await voter.functions["gauges(address)"](pool[0], {
      gasLimit: 5000000,
    });
    poolsV2.push(pool[0]);
    gaugesPoolsV2.push(gauge[0]);
  }

  // Deploy TENEX pools and gauges
  for (var i = 0; i < jsonConstants.poolsTenex.length; i++) {
    const [stable, token] = Object.values(jsonConstants.poolsTenex[i]);
    await factory.functions["createPool(address,address,bool)"](
      deployedContracts.TENEX,
      token,
      stable,
      {
        gasLimit: 5000000,
      }
    );
    let pool = await factory.functions["getPool(address,address,bool)"](
      deployedContracts.TENEX,
      token,
      stable,
      {
        gasLimit: 5000000,
      }
    );
    await voter.createGauge(
      deployedContracts.poolFactory, // PoolFactory (v2)
      pool[0],
      { gasLimit: 5000000 }
    );
    let gauge = await voter.functions["gauges(address)"](pool[0], {
      gasLimit: 5000000,
    });
    poolsV2.push(pool[0]);
    gaugesPoolsV2.push(gauge[0]);
  }

  const outputDirectory = "script/constants/output";
  const outputFile = join(
    process.cwd(),
    outputDirectory,
    "TenexOutputPools2.json"
  );

  let output = {
    poolsV2: poolsV2,
    gaugesPoolsV2: gaugesPoolsV2,
  };

  try {
    await writeFile(outputFile, JSON.stringify(output, null, 2));
  } catch (err) {
    console.error(`Error writing output file: ${err}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
