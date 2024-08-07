// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";

contract DeployTenex is Base {
    using stdJson for string;
    string public basePath;
    string public path;

    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");

    address public deployerAddress = vm.addr(deployPrivateKey);

    string public constantsFilename = vm.envString("CONSTANTS_FILENAME");
    string public outputFilename = vm.envString("OUTPUT_FILENAME");
    string public jsonConstants;
    string public jsonOutput;

    // Vars to be set in each deploy script
    address feeManager;
    address team;
    address emergencyCouncil;
    bytes32 merkleRoot;

    constructor() {
        string memory root = vm.projectRoot();
        basePath = string.concat(root, "/script/constants/");

        // load constants
        path = string.concat(basePath, constantsFilename);
        jsonConstants = vm.readFile(path);
        WETH = IWETH(abi.decode(vm.parseJson(jsonConstants, ".WETH"), (address)));
        allowedManager = abi.decode(vm.parseJson(jsonConstants, ".allowedManager"), (address));
        team = abi.decode(vm.parseJson(jsonConstants, ".team"), (address));
        feeManager = abi.decode(vm.parseJson(jsonConstants, ".feeManager"), (address));
        emergencyCouncil = abi.decode(vm.parseJson(jsonConstants, ".emergencyCouncil"), (address));
        merkleRoot = abi.decode(vm.parseJson(jsonConstants, ".merkleRoot"), (bytes32));
    }

    function run() public {
        _deploySetupBefore();
        _coreSetup();
        _deploySetupAfter();
    }

    function _deploySetupBefore() public {
        // more constants loading - this needs to be done in-memory and not storage
        address[] memory _tokens = abi.decode(vm.parseJson(jsonConstants, ".whitelistTokens"), (address[]));
        for (uint256 i = 0; i < _tokens.length; i++) {
            tokens.push(_tokens[i]);
        }

        // Loading output and use output path to later save deployed contracts
        basePath = string.concat(basePath, "output/");
        path = string.concat(basePath, "DeployTenex-");
        path = string.concat(path, outputFilename);

        // start broadcasting transactions
        vm.startBroadcast(deployPrivateKey);

        // deploy TENEX
        TENEX = Tenex(abi.decode(vm.parseJson(jsonConstants, ".TENEX"), (address)));
        //TENEX = new Tenex(); // for forking

        merkleClaim = new MerkleClaim(address(TENEX), merkleRoot);

        tokens.push(address(TENEX));

        TENEX.setMerkleClaim(address(merkleClaim));// need to verify ; placement of this transaction
    }

    function _deploySetupAfter() public {
        // Set protocol state to team
        escrow.setTeam(team);
        minter.setTeam(team);
        factory.setPauser(team);
        voter.setEmergencyCouncil(emergencyCouncil);
        voter.setEpochGovernor(team);
        voter.setGovernor(team);
        factoryRegistry.transferOwnership(team);

        // Set contract vars
        factory.setFeeManager(feeManager);
        factory.setVoter(address(voter));

        minter.acceptTeam();// need to verify

        // finish broadcasting transactions
        vm.stopBroadcast();

        // write to file
        vm.writeJson(vm.serializeAddress("v2", "TENEX", address(TENEX)), path);
        vm.writeJson(vm.serializeAddress("v2", "VotingEscrow", address(escrow)), path);
        vm.writeJson(vm.serializeAddress("v2", "Forwarder", address(forwarder)), path);
        vm.writeJson(vm.serializeAddress("v2", "ArtProxy", address(artProxy)), path);
        vm.writeJson(vm.serializeAddress("v2", "Distributor", address(distributor)), path);
        vm.writeJson(vm.serializeAddress("v2", "Voter", address(voter)), path);
        vm.writeJson(vm.serializeAddress("v2", "Router", address(router)), path);
        vm.writeJson(vm.serializeAddress("v2", "Minter", address(minter)), path);
        vm.writeJson(vm.serializeAddress("v2", "PoolFactory", address(factory)), path);
        vm.writeJson(vm.serializeAddress("v2", "VotingRewardsFactory", address(votingRewardsFactory)), path);
        vm.writeJson(vm.serializeAddress("v2", "GaugeFactory", address(gaugeFactory)), path);
        vm.writeJson(vm.serializeAddress("v2", "ManagedRewardsFactory", address(managedRewardsFactory)), path);
        vm.writeJson(vm.serializeAddress("v2", "FactoryRegistry", address(factoryRegistry)), path);
    }
}
