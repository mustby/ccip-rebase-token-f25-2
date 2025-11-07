// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

// This is where the ETH is locked up/stored
// Do we need onlyOwner permission to withdraw excess funds?

contract Vault {
    // we need to pass the token address to the constructor
    // create a deposit function that mints token to the user equal to the amount of ETH they send
    // create a redeem function that burns the token from the user and sends user ETH
    // create a way to add rewards to the vault

    IRebaseToken private immutable i_rebaseToken;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Vault__RedeemFailed();

    // Make the "type" IRebaseToken

    constructor(IRebaseToken _rebaseToken) {
        i_rebaseToken = _rebaseToken;
    }

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Allows users to deposit ETH into the vault and mint rebase tokens in return
     */

    function deposit() external payable {
        // 1. we need to use the amount of ETH the user has sent to mint the same amount of tokens to the user
        uint256 interestRate = i_rebaseToken.getInterestRate();
        i_rebaseToken.mint(msg.sender, msg.value, interestRate);
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @notice Allows users to redeem their rebase tokens for ETH
     * @param _amount The amount of rebase tokens to redeem
     */

    function redeem(uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        // 1. we need to burn the amount of tokens from the user
        i_rebaseToken.burn(msg.sender, _amount);
        // 2. we need to send the user the amount of ETH equal to the amount of tokens they have burned
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                            GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the address of the rebase token
     * @return i_rebaseToken The address of the rebase token
     */

    function getRebaseTokenAddress() external view returns (address) {
        return address(i_rebaseToken);
    }
}
