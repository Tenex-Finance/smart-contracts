// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/StdJson.sol";
import "../test/Base.sol";
import "forge-std/console.sol";

contract DeployMockTokens is Base {
    uint256 public deployPrivateKey = vm.envUint("PRIVATE_KEY_DEPLOY");

    uint256 public constant INITIAL_SUPPLY = 100_000_000;
    uint256 public constant MAX_RETRIES = 3;

    function run() public {
        _deployTokens();
    }

    // deploy Mock Tokens
    function _deployTokens() public {
        // start broadcasting transactions
        vm.startBroadcast(deployPrivateKey);

        // Deploy tokens with retries and logging
        _deploySingleToken(0, "Tenex Usdc", "tUSDC", 6);
        _deploySingleToken(1, "Tenex Bsc", "tBSC", 18);
        _deploySingleToken(2, "Tenex Envio", "tENVIO", 18);
        _deploySingleToken(3, "Tenex OP", "tOP", 18);
        _deploySingleToken(4, "Tenex Aave", "tAAVE", 18);
        _deploySingleToken(5, "Tenex Curve", "tCURVE", 18);

        vm.stopBroadcast();
    }

    function _deploySingleToken(uint256 index, string memory name, string memory symbol, uint8 decimals) internal {
        uint256 retries = 0;
        while (retries < MAX_RETRIES) {
            try new tMockToken(INITIAL_SUPPLY, name, symbol, decimals) returns (tMockToken token) {
                TMOCK[index] = token;
                console.log("Successfully deployed", name, address(token));
                return;
            } catch Error(string memory reason) {
                console.log("Error deploying", name, ":", reason);
            } catch (bytes memory) {
                console.log("Error deploying", name);
            }
            retries++;
        }
        require(retries < MAX_RETRIES, string(abi.encodePacked("Failed to deploy ", name, " after ", MAX_RETRIES, " attempts")));
    }
}
