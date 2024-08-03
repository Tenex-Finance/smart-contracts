// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";
import "forge-std/console.sol";

contract DeployMockTokens is Base {
    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");

    uint256 public constant INITIAL_SUPPLY = 100_000_000;

    function run() public {
        _deployTokens();
    }

    // deploy Mock Tokens
    function _deployTokens() public {
        // start broadcasting transactions
        vm.startBroadcast(deployPrivateKey);

        TMOCK[0] = new tMockToken(INITIAL_SUPPLY, "Tenex Usdc", "tUSDC", 6);
        TMOCK[1] = new tMockToken(INITIAL_SUPPLY, "Tenex Blast", "tBLAST", 18);
        TMOCK[2] = new tMockToken(INITIAL_SUPPLY, "Tenex Envio", "tENVIO", 18);
        TMOCK[3] = new tMockToken(INITIAL_SUPPLY, "Tenex OP", "tOP", 18);
        TMOCK[4] = new tMockToken(INITIAL_SUPPLY, "Tenex Aave", "tAAVE", 18);
        TMOCK[5] = new tMockToken(INITIAL_SUPPLY, "Tenex Curve", "tCURVE", 18);


        vm.stopBroadcast();
    }
}
