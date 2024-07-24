// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import {ITenex} from "./interfaces/ITenex.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title Tenex
/// @author tenex.finance
/// @notice The native token in the Tenex ecosystem
/// @dev Emitted by the Minter
contract Tenex is ITenex, ERC20Permit {
    address public minter;
    address private owner;
    address public merkleClaim;
    address public redemptionReceiver;
    bool public initialMinted;

    constructor() ERC20("Tenex", "TENEX") ERC20Permit("Tenex") {
        minter = msg.sender;
        owner = msg.sender;
    }

    /// @dev No checks as its meant to be once off to set minting rights to BaseV1 Minter
    function setMinter(address _minter) external {
        if (msg.sender != minter) revert NotMinter();
        minter = _minter;
    }

    function setMerkleClaim(address _merkleClaim) external {
        if (msg.sender != minter) revert NotMinter();
        merkleClaim = _merkleClaim;
    }

    function setRedemptionReceiver(address _receiver) external {
        if (msg.sender != minter) revert NotMinter();
        redemptionReceiver = _receiver;
    }

    // Initial mint: total 100M
    function initialMint(address _recipient) external {
        if (msg.sender != minter) revert NotMinter();
        if (initialMinted) revert AlreadyMinted();
        initialMinted = true;
        _mint(_recipient, 100 * 1e6 * 1e18);
    }

    function mint(address account, uint256 amount) external returns (bool) {
        if (msg.sender != minter) revert NotMinter();
        _mint(account, amount);
        return true;
    }

    function claim(address account, uint amount) external returns (bool) {
        if (msg.sender != redemptionReceiver && msg.sender != merkleClaim) {
            revert ClaimNotAllowed();
        }
        _mint(account, amount);
        return true;
    }
}
