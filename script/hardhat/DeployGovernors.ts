import { deploy } from "./utils/helpers";
import { TenexGovernor, EpochGovernor } from "../../artifacts/types";
import jsonConstants from "../constants/Bsc.json";
import deployedContracts from "../constants/output/TenexOutput2.json";
import {join} from "path";
import { writeFile } from "fs/promises";

async function main() {
  const governor = await deploy<TenexGovernor>(
    "TenexGovernor",
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

  await governor.setVetoer(jsonConstants.vetoer);
  await governor.setTeam(jsonConstants.team);

  console.log(`Governor deployed to: ${governor.address}`);
  console.log(`EpochGovernor deployed to: ${epochGovernor.address}`);


  const outputDirectory = "script/constants/output";
  const outputFile = join(process.cwd(), outputDirectory, "TenexOutputGovernor.json");

  let output = {
    governor : governor.address,
    epochGovernor : epochGovernor.address
  }

  try {
    await writeFile(outputFile, JSON.stringify(output, null, 2));
  } catch (err) {
    console.error(`Error writing output file: ${err}`);
  }
  
  //For Output2
  //Governor deployed to: 0x8C2Dc92b92606b2ef8Ef6e83fd3A35F15E38ca9B
  //EpochGovernor deployed to: 0xA36515BE189acD20dF2C9e9959D898aDe08e9EB2
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
