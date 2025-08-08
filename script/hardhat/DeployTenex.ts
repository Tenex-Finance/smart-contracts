import { deploy, deployLibrary, getContractAt } from "./utils/helpers";
import { writeFile } from "fs/promises";
import { join } from "path";
import { Libraries } from "hardhat/types";
import {
  ManagedRewardsFactory,
  VotingRewardsFactory,
  GaugeFactory,
  PoolFactory,
  FactoryRegistry,
  Pool,
  Minter,
  RewardsDistributor,
  Router,
  Tenex,
  Voter,
  VeArtProxy,
  VotingEscrow,
  TenexForwarder,
  MerkleClaim,
} from "../../artifacts/types";
import jsonConstants from "../constants/Bsc.json";

interface TenexOutput {
  artProxy: string;
  distributor: string;
  factoryRegistry: string;
  forwarder: string;
  gaugeFactory: string;
  managedRewardsFactory: string;
  minter: string;
  poolFactory: string;
  router: string;
  TENEX: string;
  voter: string;
  votingEscrow: string;
  votingRewardsFactory: string;
}

async function main() {
  // ====== start _deploySetupBefore() ======

  const TENEX_ADDRESS = jsonConstants.TENEX;

  const merkleRoot = jsonConstants.merkleRoot;


  const TENEX = await getContractAt<Tenex>("Tenex", TENEX_ADDRESS);

  jsonConstants.whitelistTokens.push(TENEX_ADDRESS);
  // ====== end _deploySetupBefore() ======

  // ====== start _coreSetup() ======

  // ====== start deployFactories() ======
  const implementation = await deploy<Pool>("Pool");

  const poolFactory = await deploy<PoolFactory>(
    "PoolFactory",
    undefined,
    implementation.address
  );
  await poolFactory.setFee(true, 1);
  await poolFactory.setFee(false, 1);

  const votingRewardsFactory = await deploy<VotingRewardsFactory>(
    "VotingRewardsFactory"
  );

  const gaugeFactory = await deploy<GaugeFactory>("GaugeFactory");

  const managedRewardsFactory = await deploy<ManagedRewardsFactory>(
    "ManagedRewardsFactory"
  );

  const factoryRegistry = await deploy<FactoryRegistry>(
    "FactoryRegistry",
    undefined,
    poolFactory.address,
    votingRewardsFactory.address,
    gaugeFactory.address,
    managedRewardsFactory.address
  );
  // ====== end deployFactories() ======

  const forwarder = await deploy<TenexForwarder>("TenexForwarder");

  const balanceLogicLibrary = await deployLibrary("BalanceLogicLibrary");
  const delegationLogicLibrary = await deployLibrary("DelegationLogicLibrary");
  const libraries: Libraries = {
    BalanceLogicLibrary: balanceLogicLibrary.address,
    DelegationLogicLibrary: delegationLogicLibrary.address,
  };

  const escrow = await deploy<VotingEscrow>(
    "VotingEscrow",
    libraries,
    forwarder.address,
    TENEX_ADDRESS,
    factoryRegistry.address
  );

  const trig = await deployLibrary("Trig");
  const perlinNoise = await deployLibrary("PerlinNoise");
  const artLibraries: Libraries = {
    Trig: trig.address,
    PerlinNoise: perlinNoise.address,
  };

  const artProxy = await deploy<VeArtProxy>(
    "VeArtProxy",
    artLibraries,
    escrow.address
  );
  await escrow.setArtProxy(artProxy.address);

  const distributor = await deploy<RewardsDistributor>(
    "RewardsDistributor",
    undefined,
    escrow.address
  );

  const voter = await deploy<Voter>(
    "Voter",
    undefined,
    forwarder.address,
    escrow.address,
    factoryRegistry.address
  );

  await escrow.setVoterAndDistributor(voter.address, distributor.address);

  // Add merkle root deployment

  const router = await deploy<Router>(
    "Router",
    undefined,
    forwarder.address,
    factoryRegistry.address,
    poolFactory.address,
    voter.address,
    jsonConstants.WETH
  );

  const merkleClaim = await deploy<MerkleClaim>(
    "MerkleClaim",
    undefined,
    TENEX_ADDRESS,
    merkleRoot
  )
  

  const minter = await deploy<Minter>(
    "Minter",
    undefined,
    voter.address,
    escrow.address,
    distributor.address
  );

  await distributor.setMinter(minter.address);

  //Initial Mint
  await TENEX.initialMint(jsonConstants.team);

  await TENEX.setMerkleClaim(merkleClaim.address);
  
  await TENEX.setMinter(minter.address);
  
  // Initialize 
  await voter.initialize(jsonConstants.whitelistTokens, minter.address);
  // ====== end _coreSetup() ======

  // ====== start _deploySetupAfter() ======
  await escrow.setTeam(jsonConstants.team);
  await minter.setTeam(jsonConstants.team);
  await poolFactory.setPauser(jsonConstants.team);
  await voter.setEmergencyCouncil(jsonConstants.team);
  await voter.setEpochGovernor(jsonConstants.team);
  await voter.setGovernor(jsonConstants.team);
  await factoryRegistry.transferOwnership(jsonConstants.team);

  await poolFactory.setFeeManager(jsonConstants.feeManager);
  await poolFactory.setVoter(voter.address);
  // ====== end _deploySetupAfter() ======

  const outputDirectory = "script/constants/output";
  const outputFile = join(process.cwd(), outputDirectory, "TenexOutput2.json");

  const output: TenexOutput = {
    artProxy: artProxy.address,
    distributor: distributor.address,
    factoryRegistry: factoryRegistry.address,
    forwarder: forwarder.address,
    gaugeFactory: gaugeFactory.address,
    managedRewardsFactory: managedRewardsFactory.address,
    minter: minter.address,
    poolFactory: poolFactory.address,
    router: router.address,
    TENEX: TENEX_ADDRESS,
    voter: voter.address,
    votingEscrow: escrow.address,
    votingRewardsFactory: votingRewardsFactory.address,
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
