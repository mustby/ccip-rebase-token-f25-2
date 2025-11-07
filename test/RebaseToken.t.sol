// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "lib/forge-std/src/Test.sol";

import {RebaseToken} from "src/RebaseToken.sol";
import {Vault} from "src/Vault.sol";

import {IRebaseToken} from "src/interfaces/IRebaseToken.sol";

contract RebaseTokenTest is Test {
    RebaseToken private rebaseToken;
    Vault private vault;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        rebaseToken = new RebaseToken(); // deploying rebase token
        vault = new Vault(IRebaseToken(address(rebaseToken))); // redploying vault with rebase token address
        rebaseToken.grantMintAndBurnRole(address(vault)); // granting mint and burn role to vault
        (bool success,) = payable(address(vault)).call{value: 1e18}(""); // Adding some funds to the vault - 1 ETH
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                               FUZZ TESTS
    //////////////////////////////////////////////////////////////*/

    function testDepositLinear(uint256 amount) public {
        // vm.assume(amount > 1e5); // this will waste a lot of runs versus just using "bound"
        amount = bound(amount, 1e5, type(uint96).max);
        // 1. deposit
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        // 2. check out rebase token balance
        uint256 startBalance = rebaseToken.balanceOf(user);
        console.log("startBalance:", startBalance);
        assertEq(startBalance, amount);
        // 3. warp the time and check the balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 newBalance = rebaseToken.balanceOf(user);
        assertGt(newBalance, startBalance);
        // 4. warp the time again by the same amount and check the balance again
        vm.warp(block.timestamp + 1 hours);
        uint256 newerBalance = rebaseToken.balanceOf(user);
        assertGt(newerBalance, newBalance);
        // 5. the difference between newBalance and balance should be equal to the difference between newerBalance and newBalance
        assertApproxEqAbs(newBalance - startBalance, newerBalance - newBalance, 1);
        vm.stopPrank();
    }

    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        // 1. deposit
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        assertEq(rebaseToken.balanceOf(user), amount);
        // 2. redeem straight away
        vault.redeem(type(uint256).max);
        assertEq(rebaseToken.balanceOf(user), 0);
        assertEq(address(user).balance, amount);
        vm.stopPrank();
    }

    function testInterestRateCanOnlyGoDown() public {}
}
