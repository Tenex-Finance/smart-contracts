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
    address public merkleClaim;
    bool public initialMinted;

    constructor() ERC20("Tenex", "TENEX") ERC20Permit("Tenex") {
        minter = msg.sender;
    }

    modifier onlyMinter() {
        if (msg.sender != minter) revert NotMinter();
        _;
    }

    modifier checkAddress(address _account) {
        if (_account == address(0)) revert ZeroAddress();
        _;
    }

    /// @notice Set the minter address
    /// @param _minter The address to set as the minter
    function setMinter(address _minter) external checkAddress(_minter) onlyMinter {
        minter = _minter;
        emit SetMinter(minter);
    }

    /// @notice Set the merkle claim address
    /// @param _merkleClaim The address to set for merkle claims
    function setMerkleClaim(address _merkleClaim) external checkAddress(_merkleClaim) onlyMinter {
        merkleClaim = _merkleClaim;
        emit SetMerkleClaim(merkleClaim);
    }

    /// @notice Initial mint of 100 million tokens
    /// @param _recipient The address to receive the initial mint
    function initialMint(address _recipient) external checkAddress(_recipient) onlyMinter {
        if (initialMinted) revert AlreadyMinted();
        initialMinted = true;
        _mint(_recipient, 100 * 1e6 * 1e18);
        emit InitialMinted(_recipient);
    }

    /// @notice Mint tokens to an account
    /// @param account The address to receive the minted tokens
    /// @param amount The amount of tokens to mint
    /// @return success Returns true if minting is successful
    function mint(address account, uint256 amount) external onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }

    /// @notice Claim tokens
    /// @param account The address to receive the claimed tokens
    /// @param amount The amount of tokens to claim
    /// @return success Returns true if claiming is successful
    function claim(address account, uint amount) external returns (bool) {
        if (msg.sender != merkleClaim) {
            revert ClaimNotAllowed();
        }
        _mint(account, amount);
        return true;
    }
}
