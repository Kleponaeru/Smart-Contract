// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Vault is ERC20 {
    address public usdc;

    error InsufficientBalance();

    event Deposit(address indexed user, uint256 amount);
    event TestEvent(uint256 indexed param1, uint256 indexed param2, uint256 indexed param3, uint256 param4);
    event Withdraw(address indexed user, uint256 amount);
    event DistributeYield(address indexed user, uint256 amount);

    constructor(address _usdc) ERC20("Lucyfer Vault", "LCY") {
        usdc = _usdc;
    }

    function callTestEvent() public {
        emit TestEvent(1, 2, 3, 4);
    }

    function deposit(uint256 amount) external {
        if (IERC20(usdc).balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        // Condition has to meet no matter what
        // require(IERC20(usdc).balanceOf(msg.sender) >= amount, "Transfer amount exceed allowance");

        uint256 totalAsset = IERC20(usdc).balanceOf(address(this));
        uint256 totalShare = totalSupply();

        uint256 shares = 0;
        if (totalShare == 0) {
            shares = amount;
        } else {
            shares = (amount * totalShare) / totalAsset;
        }

        _mint(msg.sender, shares);
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 shares) external {
        if (balanceOf(msg.sender) < shares) {
            revert InsufficientBalance();
        }

        uint256 totalAsset = IERC20(usdc).balanceOf(address(this));
        uint256 totalShare = totalSupply();

        uint256 amount = (shares * totalAsset) / totalShare;

        _burn(msg.sender, shares);

        if (IERC20(usdc).balanceOf(address(this)) < amount) {
            revert InsufficientBalance();
        }

        // transfer usdc from vault to msg.sender
        IERC20(usdc).transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function distributeYield(uint256 amount) external {
        if (IERC20(usdc).balanceOf(msg.sender) < amount) {
            revert InsufficientBalance();
        }

        // Transfer USDC from the caller to the vault
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);

        emit DistributeYield(msg.sender, amount);
    }
}
