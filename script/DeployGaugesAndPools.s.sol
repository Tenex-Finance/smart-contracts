// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";
import "forge-std/console.sol";

/// @notice Deploy script to deploy new pools and gauges for v2
contract DeployGaugesAndPools is Script {
    using stdJson for string;

    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");
    address public deployerAddress = vm.addr(deployPrivateKey);
    string public constantsFilename = vm.envString("CONSTANTS_FILENAME");
    string public outputFilename = vm.envString("OUTPUT_FILENAME");
    string public jsonConstants;
    string public jsonOutput;

    PoolFactory public factory;
    Voter public voter;
    address public TENEX;

    struct PoolV2 {
        bool stable;
        address tokenA;
        address tokenB;
    }

    struct PoolTENEXV2 {
        bool stable;
        address token;
    }

    address[] poolsV2;
    address[] gauges;

    constructor() {}

    function run() public {
        string memory root = vm.projectRoot();
        string memory basePath = string.concat(root, "/script/constants/");
        string memory path = string.concat(basePath, constantsFilename);

        // load in vars
        jsonConstants = vm.readFile(path);
        PoolV2[] memory pools = abi.decode(jsonConstants.parseRaw(".poolsV2"), (PoolV2[]));
        PoolTENEXV2[] memory poolsTENEX = abi.decode(jsonConstants.parseRaw(".poolsTENEXV2"), (PoolTENEXV2[]));

        path = string.concat(basePath, "output/DeployTENEXdromeV2-");
        path = string.concat(path, outputFilename);
        jsonOutput = vm.readFile(path);
        factory = PoolFactory(abi.decode(jsonOutput.parseRaw(".PoolFactory"), (address)));
        voter = Voter(abi.decode(jsonOutput.parseRaw(".Voter"), (address)));
        TENEX = abi.decode(jsonOutput.parseRaw(".TENEX"), (address));

        vm.startBroadcast(deployerAddress);

        // Deploy all non-TENEX pools & gauges
        for (uint256 i = 0; i < pools.length; i++) {
            console.log("runing---->");
            address newPool = factory.createPool(pools[i].tokenA, pools[i].tokenB, pools[i].stable);
            console.log(newPool);
            address newGauge = voter.createGauge(address(factory), newPool);

            poolsV2.push(newPool);
            gauges.push(newGauge);
        }

        // Deploy all TENEX pools & gauges
        for (uint256 i = 0; i < poolsTENEX.length; i++) {
            address newPool = factory.createPool(TENEX, poolsTENEX[i].token, poolsTENEX[i].stable);
            address newGauge = voter.createGauge(address(factory), newPool);

            poolsV2.push(newPool);
            gauges.push(newGauge);
        }

        vm.stopBroadcast();

        // Write to file
        path = string.concat(basePath, "output/DeployGaugesAndPoolsV2-");
        path = string.concat(path, outputFilename);
        vm.writeJson(vm.serializeAddress("v2", "gaugesPoolsV2", gauges), path);
        vm.writeJson(vm.serializeAddress("v2", "poolsV2", poolsV2), path);
    }
}
