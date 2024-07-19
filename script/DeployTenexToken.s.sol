// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";
import "forge-std/console.sol";

contract DeployTenexToken is Base {
    using stdJson for string;
    string public basePath;
    string public path;

    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");

    address public deployerAddress = vm.addr(deployPrivateKey);

    function run() public {
        _deployToken();
    }

    function _deployToken() public {
        // deploy TENEX
        // start broadcasting transactions
        vm.startBroadcast(deployPrivateKey);
        TENEX = new Tenex();

        vm.stopBroadcast();
        
        console.log("tenex-----", address(TENEX));
    }
}
