// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract tMockToken is ERC20Permit {
    address private owner;
    uint8 private _decimals;

    struct UserStatus {
        uint256 lastClaimed;
        uint256 amountClaimed;
    }

    mapping(address => UserStatus) claimStatus;
    uint256 public constant MAX_LIMIT = 10_000;

    constructor(
        uint256 initialSupply_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_
    ) ERC20(name_, symbol_) ERC20Permit(name_) {
        owner = msg.sender;
        _decimals = uint8(decimals_);
        _mint(msg.sender, initialSupply_ * 10 ** _decimals);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    modifier claimable() {
        require(claimStatus[msg.sender].amountClaimed < MAX_LIMIT, "You have reached your limit");
        require(
            block.timestamp >= claimStatus[msg.sender].lastClaimed + 1 days,
            "You can only claim once every 24 hours"
        );
        _;
    }

    function claim() public claimable {
        claimStatus[msg.sender].lastClaimed = block.timestamp;
        claimStatus[msg.sender].amountClaimed += 1000;
        _mint(msg.sender, 1000 * 10 ** _decimals);
    }

    function mintTo(address _recipient, uint256 _amount) external {
        require(msg.sender == owner, "Not Allowed");

        _mint(_recipient, _amount * 10 ** _decimals);
    }
}
