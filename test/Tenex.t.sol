// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;
import {ITenex, Tenex} from "contracts/Tenex.sol";

import "./BaseTest.sol";

contract TenexTest is BaseTest {
    Tenex token;
    address recipient = address(0x456);
    address redemptionReceiver = address(0x2);
    address _merkleClaim = address(0x3);
    address user1 = address(0x4);
    address user2 = address(0);

    function _setUp() public override {
        token = new Tenex();
        // Set the minter
        vm.prank(token.minter());
        token.setMinter(address(owner5));

        // Set the redemptionReceiver
        vm.prank(address(owner5));
        token.setRedemptionReceiver(redemptionReceiver);

        // Set the merkleClaim
        vm.prank(address(owner5));
        token.setMerkleClaim(address(_merkleClaim));
    }

    function testCannotSetMinterIfNotMinter() public {
        vm.prank(address(owner2));
        vm.expectRevert(ITenex.NotMinter.selector);
        token.setMinter(address(owner3));
    }

    function testSetMinter() public {
        vm.prank(address(owner5));
        token.setMinter(address(owner3));

        assertEq(token.minter(), address(owner3));
    }

    function testSetMerkleClaim() public {
        vm.prank(address(owner5));
        token.setMerkleClaim(address(owner2));

        assertEq(token.merkleClaim(), address(owner2));
    }

    function testSetRedemptionReceiver() public {
        vm.prank(address(owner5));
        token.setRedemptionReceiver(address(owner4));

        assertEq(token.redemptionReceiver(), address(owner4));
    }

    function testInitialMint() public {
        // Check initial conditions
        assertEq(token.initialMinted(), false);

        vm.prank(address(owner5)); // Set msg.sender to minter
        // Perform the mint
        token.initialMint(recipient);

        // // Check the final state
        assertEq(token.initialMinted(), true);
        assertEq(token.balanceOf(recipient), 100 * 1e6 * 1e18);
    }

    function testFailInitialMintNotMinter() public {
        // This test should fail because msg.sender is not the minter
        vm.prank(address(0x789));
        token.initialMint(recipient);
    }

    function testFailInitialMintAlreadyMinted() public {
        // Mint once
        vm.prank(address(owner5));
        token.initialMint(recipient);

        // This test should fail because initialMinted is true
        vm.prank(address(owner5));
        token.initialMint(recipient);
    }

    function testCannotMintIfNotMinter() public {
        vm.prank(address(owner2));
        vm.expectRevert(ITenex.NotMinter.selector);
        token.mint(address(owner2), TOKEN_1);
    }

    function testClaimByRedemptionReceiver() public {
        vm.prank(redemptionReceiver);
        token.claim(user1, 1000);

        assertEq(token.balanceOf(user1), 1000);
        assertEq(token.totalSupply(), 1000);
    }

    function testFailClaimByRedemptionReceiver() public {
        vm.prank(redemptionReceiver);
        token.claim(user2, 1000);

        assertEq(token.balanceOf(user2), 1000);
        assertEq(token.totalSupply(), 1000);
    }

    function testClaimByMerkleClaim() public {
        vm.prank(address(_merkleClaim));
        token.claim(user1, 2000);

        assertEq(token.balanceOf(user1), 2000);
        assertEq(token.totalSupply(), 2000);
    }

    function testClaimByUnauthorizedAddress() public {
        vm.prank(user1);
        vm.expectRevert(ITenex.ClaimNotAllowed.selector);
        token.claim(user1, 3000);
    }
}
