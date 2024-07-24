// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.19;

import "./BaseTest.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleClaimTest is BaseTest {
    bytes32 public merkleRoot;
    address public claimer = address(0x1);
    address public nonClaimer = address(0x2);
    uint256 public amount = 1000;
    //MerkleClaim public merkleClaim;

    function _setUp() public override {
        // Create a simple Merkle tree with one leaf
        bytes32 leaf = keccak256(abi.encodePacked(claimer, amount));
        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = leaf;
        merkleRoot = keccak256(abi.encodePacked(leaf));

        // Deploy MerkleClaim contract with the prepared Merkle root
        merkleClaim = new MerkleClaim(address(TENEX), merkleRoot);
    }


    //@Todo
    // function testClaim() public {
    //     // Create a proof for the claimer
    //     bytes32[] memory proof = new bytes32[](1);
    //     proof[0] = keccak256(abi.encodePacked(claimer, amount));

    //     // Make sure the proof verifies correctly
    //     assert(MerkleProof.verify(proof, merkleRoot, keccak256(abi.encodePacked(claimer, amount))));

    //     vm.prank(claimer);
    //     merkleClaim.claim(claimer, amount, proof);

    //     assertEq(TENEX.balanceOf(claimer), amount);
    //     assertTrue(merkleClaim.hasClaimed(claimer));
    // }

    // function testClaimTwice() public {
    //     // Create a proof for the claimer
    //     bytes32[] memory proof = new bytes32[](1);
    //     proof[0] = keccak256(abi.encodePacked(claimer, amount));

    //     vm.prank(claimer);
    //     merkleClaim.claim(claimer, amount, proof);

    //     vm.expectRevert("ALREADY_CLAIMED");
    //     vm.prank(claimer);
    //     merkleClaim.claim(claimer, amount, proof);
    // }

    function testClaimWithInvalidProof() public {
        // Create an invalid proof for the nonClaimer
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = keccak256(abi.encodePacked(nonClaimer, amount));

        vm.expectRevert("NOT_IN_MERKLE");
        vm.prank(nonClaimer);
        merkleClaim.claim(nonClaimer, amount, proof);
    }
}
