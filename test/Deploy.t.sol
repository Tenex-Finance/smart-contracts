// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "../script/DeployTenex.s.sol";
import "../script/DeployGaugesAndPools.s.sol";
import "../script/DeployGovernors.s.sol";

import "./BaseTest.sol";

contract TestDeploy is BaseTest {
    using stdJson for string;
    using stdStorage for StdStorage;

    string public constantsFilename = vm.envString("CONSTANTS_FILENAME");
    string public jsonConstants;

    address public feeManager;
    address public team;
    address public emergencyCouncil;
    address public constant testDeployer = address(1);

    struct PoolV2 {
        bool stable;
        address tokenA;
        address tokenB;
    }

    struct PoolTenex {
        bool stable;
        address token;
    }

    // Scripts to test
    DeployTenex deployTenex;
    DeployGaugesAndPools deployGaugesAndPools;
    DeployGovernors deployGovernors;

    constructor() {
        deploymentType = Deployment.CUSTOM;
    }

    function _setUp() public override {
        _forkSetupBefore();

        deployTenex = new DeployTenex();
        deployGaugesAndPools = new DeployGaugesAndPools();
        deployGovernors = new DeployGovernors();

        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/script/constants/");
        path = string.concat(path, constantsFilename);

        jsonConstants = vm.readFile(path);

        WETH = IWETH(abi.decode(vm.parseJson(jsonConstants, ".WETH"), (address)));
        team = abi.decode(vm.parseJson(jsonConstants, ".team"), (address));
        feeManager = abi.decode(vm.parseJson(jsonConstants, ".feeManager"), (address));
        emergencyCouncil = abi.decode(vm.parseJson(jsonConstants, ".emergencyCouncil"), (address));

        // Use test account for deployment
        stdstore.target(address(deployTenex)).sig("deployerAddress()").checked_write(testDeployer);
        stdstore.target(address(deployGaugesAndPools)).sig("deployerAddress()").checked_write(testDeployer);
        stdstore.target(address(deployGovernors)).sig("deployerAddress()").checked_write(testDeployer);
        vm.deal(testDeployer, TOKEN_10K);
    }

    function testLoadedState() public {
        // If tests fail at this point- you need to set the .env and the constants used for deployment.
        // Refer to script/README.md
        assertTrue(address(WETH) != address(0));
        assertTrue(team != address(0));
        assertTrue(feeManager != address(0));
        assertTrue(emergencyCouncil != address(0));
    }

    function testDeployScript() public {
        deployTenex.run();
        deployGaugesAndPools.run();

        assertEq(deployTenex.voter().epochGovernor(), team);
        assertEq(deployTenex.voter().governor(), team);

        // deployTenex checks

        // ensure all tokens are added to voter
        address[] memory _tokens = abi.decode(vm.parseJson(jsonConstants, ".whitelistTokens"), (address[]));
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            assertTrue(deployTenex.voter().isWhitelistedToken(token));
        }
        assertTrue(deployTenex.voter().isWhitelistedToken(address(deployTenex.TENEX())));

        assertTrue(address(deployTenex.WETH()) == address(WETH));

        // PoolFactory
        assertEq(deployTenex.factory().voter(), address(deployTenex.voter()));
        assertEq(deployTenex.factory().stableFee(), 5);
        assertEq(deployTenex.factory().volatileFee(), 30);

        // v2 core
        // From _coreSetup()
        assertTrue(address(deployTenex.forwarder()) != address(0));
        assertEq(address(deployTenex.artProxy().ve()), address(deployTenex.escrow()));
        assertEq(deployTenex.escrow().voter(), address(deployTenex.voter()));
        assertEq(deployTenex.escrow().artProxy(), address(deployTenex.artProxy()));
        assertEq(address(deployTenex.distributor().ve()), address(deployTenex.escrow()));
        assertEq(deployTenex.router().defaultFactory(), address(deployTenex.factory()));
        assertEq(deployTenex.router().voter(), address(deployTenex.voter()));
        assertEq(address(deployTenex.router().weth()), address(WETH));
        assertEq(deployTenex.distributor().minter(), address(deployTenex.minter()));
        assertEq(deployTenex.TENEX().minter(), address(deployTenex.minter()));

        assertEq(deployTenex.voter().minter(), address(deployTenex.minter()));
        assertEq(address(deployTenex.minter().tenex()), address(deployTenex.TENEX()));
        assertEq(address(deployTenex.minter().voter()), address(deployTenex.voter()));
        assertEq(address(deployTenex.minter().ve()), address(deployTenex.escrow()));
        assertEq(address(deployTenex.minter().rewardsDistributor()), address(deployTenex.distributor()));

        // Permissions
        assertEq(address(deployTenex.minter().pendingTeam()), team);
        assertEq(deployTenex.escrow().team(), team);
        assertEq(deployTenex.escrow().allowedManager(), team);
        assertEq(deployTenex.factory().pauser(), team);
        assertEq(deployTenex.voter().emergencyCouncil(), emergencyCouncil);
        assertEq(deployTenex.voter().governor(), team);
        assertEq(deployTenex.voter().epochGovernor(), team);
        assertEq(deployTenex.factoryRegistry().owner(), team);
        assertEq(deployTenex.factory().feeManager(), feeManager);

        // deployGaugesAndPools checks

        // Validate non-TENEX pools and gauges
        PoolV2[] memory poolsV2 = abi.decode(jsonConstants.parseRaw(".poolsV2"), (PoolV2[]));
        for (uint256 i = 0; i < poolsV2.length; i++) {
            PoolV2 memory p = poolsV2[i];
            address poolAddr = deployTenex.factory().getPool(p.tokenA, p.tokenB, p.stable);
            assertTrue(poolAddr != address(0));
            address gaugeAddr = deployTenex.voter().gauges(poolAddr);
            assertTrue(gaugeAddr != address(0));
        }

        // validate TENEX pools and gauges
        PoolTenex[] memory poolsTenex = abi.decode(jsonConstants.parseRaw(".poolsTenex"), (PoolTenex[]));
        for (uint256 i = 0; i < poolsTenex.length; i++) {
            PoolTenex memory p = poolsTenex[i];
            address poolAddr = deployTenex.factory().getPool(
                address(deployTenex.TENEX()),
                p.token,
                p.stable
            );
            assertTrue(poolAddr != address(0));
            address gaugeAddr = deployTenex.voter().gauges(poolAddr);
            assertTrue(gaugeAddr != address(0));
        }
    }

    function testDeployGovernors() public {
        deployGovernors.run();

        governor = deployGovernors.governor();
        epochGovernor = deployGovernors.epochGovernor();

        assertEq(address(governor.ve()), address(deployGovernors.escrow()));
        assertEq(address(governor.token()), address(deployGovernors.escrow()));
        assertEq(governor.vetoer(), address(testDeployer));
        assertEq(governor.pendingVetoer(), address(deployGovernors.vetoer()));
        assertEq(governor.team(), address(testDeployer));
        assertEq(governor.pendingTeam(), address(deployGovernors.team()));
        assertEq(address(governor.escrow()), address(deployGovernors.escrow()));
        assertEq(address(governor.voter()), address(deployGovernors.voter()));

        assertEq(address(epochGovernor.token()), address(deployGovernors.escrow()));
        assertEq(epochGovernor.minter(), address(deployGovernors.minter()));
        assertTrue(epochGovernor.isTrustedForwarder(address(deployGovernors.forwarder())));
        assertEq(address(governor.escrow()), address(deployGovernors.escrow()));
        assertEq(address(governor.voter()), address(deployGovernors.voter()));
    }
}
