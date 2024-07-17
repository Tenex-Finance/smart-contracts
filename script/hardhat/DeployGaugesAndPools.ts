import { getContractAt } from "./utils/helpers";
import { PoolFactory, Voter } from "../../artifacts/types";
import jsonConstants from "../constants/Blast.json";
import deployedContracts from "../constants/output/TenexOutput.json";

async function main() {
  const factory = await getContractAt<PoolFactory>(
    "PoolFactory",
    deployedContracts.poolFactory
  );
  const voter = await getContractAt<Voter>("Voter", deployedContracts.voter);

  // Deploy non-VELO pools and gauges
  for (var i = 0; i < jsonConstants.pools.length; i++) {
    const { stable, tokenA, tokenB } = jsonConstants.pools[i];
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
  }

  // Deploy VELO pools and gauges
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
  }
}



main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
