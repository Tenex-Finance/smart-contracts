import { deploy, getContractAt } from "./utils/helpers";

import { Tenex } from "../../artifacts/types";

async function main() {
  // ====== start _deploySetupBefore() ======

  const Tenex = await deploy<Tenex>("Tenex");

  //const tenex = await getContractAt("Tenex","0x50BA9B7E05cE03f1a9a5D154AA4fb1523d5D70Ed")

  //console.log("-------->",tenex)

  // ====== end _deploySetupAfter() ======
  console.log(`Tenex token deployed at ${Tenex.address}`);
  //0x50BA9B7E05cE03f1a9a5D154AA4fb1523d5D70Ed
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
