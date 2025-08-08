// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITenex is IERC20 {
    error NotMinter();
    error AlreadyMinted();
    error ClaimNotAllowed();
    error ZeroAddress();

    event SetMinter(address minter);
    event SetMerkleClaim(address merkleClaim);
    event InitialMinted(address recipient);

    /// @notice Mint an amount of tokens to an account
    ///         Only callable by Minter.sol
    /// @return True if success
    function mint(address account, uint256 amount) external returns (bool);

    function setMerkleClaim(address _merkleclaim) external;

    function claim(address account, uint amount) external returns (bool);

    /// @notice Address of Minter.sol
    function minter() external view returns (address);

    /// @notice Address of MerkleClaim.sol
    function merkleClaim() external view returns (address);
}
