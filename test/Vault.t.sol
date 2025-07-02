pragma solidity ^0.8.13;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Vault} from "../src/Vault.sol";
import {MockUSDC} from "../src/MockUSDC.sol";

contract VaultTest is Test {
    Vault public vault;
    MockUSDC public usdc;
    address public user;
    address public lucy = makeAddr("lucy");

    function setUp() public {
        usdc = new MockUSDC();
        vault = new Vault(address(usdc));
    }

    function test_Deposit() public {
        vm.startPrank(lucy);
        usdc.mint(lucy, 1000);
        usdc.approve(address(vault), 1000);

        // Deposit to vault from lucy
        vault.deposit(1000);
        assertEq(vault.balanceOf(lucy), 1000);
        vm.stopPrank();
    }

    function test_Withdraw() public {
        //lucy deposit 1000 USDC
        vm.startPrank(lucy);
        usdc.mint(lucy, 1000);
        usdc.approve(address(vault), 1000);

        //Expect emit deposit event
        vm.expectEmit(true, true, true, true);
        emit Vault.Deposit(lucy, 1000);

        //Deposit 1000 USDC
        vault.deposit(1000);
        //Check balance of lucy
        assertEq(vault.balanceOf(lucy), 1000);
        vm.stopPrank();
        //Distribute yield
        usdc.mint(address(this), 1000);
        usdc.approve(address(vault), 1000);

        //Expect emit distribute yield event
        vm.expectEmit(true, true, true, true);
        emit Vault.DistributeYield(address(this), 1000);

        //Distribute 1000 USDC
        vault.distributeYield(1000);
        //check balance of vault
        assertEq(usdc.balanceOf(address(vault)), 2000);
        
        //lucy withdraw 500 USDC
        //Expect emit withdraw event
        vm.expectEmit(true, true, true, true);
        emit Vault.Withdraw(lucy, 1000);
        //Withdraw 500 USDC
        vm.prank(lucy);
        vault.withdraw(500);
        //Check balance of lucy
        assertEq(usdc.balanceOf(lucy), 1000);
    }

    //  function test_CallTestEvent() public {
    //     vm.expectEmit(true, true,true,true);
    //     emit Vault.callTestEvent();(1,2,3,4);

    //     vault.callTestEvent();
    // }
}
