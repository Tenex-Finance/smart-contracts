import { deploy } from "./utils/helpers";
import { VeloGovernor, EpochGovernor } from "../../artifacts/types";
import jsonConstants from "../constants/Blast.json";
import deployedContracts from "../constants/output/VelodromeV2Output.json";


async function main() {
  const governor = await deploy<VeloGovernor>(
    "VeloGovernor",
    undefined,
    deployedContracts.votingEscrow,
    deployedContracts.voter
  );
  const epochGovernor = await deploy<EpochGovernor>(
    "EpochGovernor",
    undefined,
    deployedContracts.forwarder,
    deployedContracts.votingEscrow,
    deployedContracts.minter,
    deployedContracts.voter
  );

  await governor.setVetoer(jsonConstants.team);
  console.log(`Governor deployed to: ${governor.address}`);
  console.log(`EpochGovernor deployed to: ${epochGovernor.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
