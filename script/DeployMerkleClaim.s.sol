// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";
import "forge-std/console.sol";

contract DeployMerkleClaim is Base {
    using stdJson for string;
    string public basePath;
    string public path;

    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");

    address public deployerAddress = vm.addr(deployPrivateKey);

    bytes32 public merkleRoot = 0xbd6c68af958c9ab9df815558f13d83a60119d22cd81df06da12f49da30481ec8;

    string public constantsFilename = vm.envString("CONSTANTS_FILENAME");
    string public outputFilename = vm.envString("OUTPUT_FILENAME");
    string public jsonConstants;

    constructor() {
        string memory root = vm.projectRoot();
        basePath = string.concat(root, "/script/constants/");

        // load constants
        path = string.concat(basePath, constantsFilename);
        jsonConstants = vm.readFile(path);
        TENEX = Tenex(abi.decode(vm.parseJson(jsonConstants, ".TENEX"), (address)));
    }

    function run() public {
        _deployMerkleClaim();
    }

    function _deployMerkleClaim() public {
        // deploy Merkle Claim
        // start broadcasting transactions

        vm.startBroadcast(deployPrivateKey);

        merkleClaim = new MerkleClaim(address(TENEX), merkleRoot);

        vm.stopBroadcast();

        console.log("merkle claim-----", address(merkleClaim));
        //0x2C20b90c92e452461f039746859B777E0a820848
    }
}
