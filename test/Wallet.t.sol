// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {Wallet, NotAnOwner} from "../src/Wallet.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public testContrct = address(this);
    address public user = makeAddr("user");

    event Deposited(uint256 indexed amount, address sender);

    function setUp() public {
        wallet = new Wallet();
    }

    function testGetBalance() public {
        assertEq(wallet.getBalance(), 0);
    }

    function testOwner() public {
        assertEq(wallet.owner(), testContrct);
        console.log(testContrct);
    }

    function testDeposit() public {
        uint256 amount = 100;

        vm.expectEmit(true, true, true, true);
        emit Deposited(amount, testContrct);

        wallet.deposit{value: amount}();
        assertEq(wallet.getBalance(), amount);
    }

    function testReceive() public {
        assertEq(wallet.getBalance(), 0);

        (bool success, ) = address(wallet).call{value: 100}("");
        assertEq(success, true);
        assertEq(wallet.getBalance(), 100);
    }

    function testDepositNotOwner() public {
        hoax(user, 2 ether);
        vm.expectRevert(abi.encodeWithSelector(NotAnOwner.selector, user));
        wallet.deposit{value: 100}();
    }

    function testWithdrawNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(NotAnOwner.selector, user));
        vm.prank(user);
        wallet.withdraw();
    }

    function testWithdrawZeroBalance() public {
        vm.expectRevert(bytes("nothing was deposited!"));
        wallet.withdraw();
    }

    function testWithdrawTooEarly() public {
        wallet.deposit{value: 100}();
        vm.expectRevert(bytes("too early"));
        wallet.withdraw();
    }

    function testWithdraw() public {
        uint256 amount = 100;

        wallet.deposit{value: amount}();
        assertEq(wallet.getBalance(), amount);

        uint256 initialBalance = testContrct.balance;
        vm.warp(wallet.lastDepositAt() + 121);

        wallet.withdraw();

        assertEq(wallet.getBalance(), 0);
        assertEq(testContrct.balance, initialBalance + amount);
    }

    receive() external payable {}
}
