// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {AtomicSwap} from "../src/AtomicSwap.sol";
import {SwapToken} from "../src/SwapToken.sol";

contract AtomicSwapTest is Test {
    // ERC20 constant USDT = ERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    AtomicSwap public contractChainA;
    AtomicSwap public contractChainB;
    SwapToken public tokenChainA;
    SwapToken public tokenChainB;
    address public userChainA = makeAddr("userA");
    address public userChainB = makeAddr("userB");

    event SwapInitiated(
        uint256 indexed id,
        address from,
        address to,
        bytes32 hash
    );
    event SwapSuccessful(uint256 indexed id, bytes password);
    event SwapCanceled(uint256 indexed id);

    function setUp() public {
        // vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/UXIG2RYPxfZqN8bbQ9oIWYOCsLVUSvSK");

        vm.startPrank(userChainA);
        tokenChainA = new SwapToken();
        contractChainA = new AtomicSwap(tokenChainA);

        changePrank(userChainB);
        tokenChainB = new SwapToken();
        contractChainB = new AtomicSwap(tokenChainB);
    }

    function test_MakeHash() public {
        bytes32 hash = contractChainA.makeHash("complex password");
        assertEq(
            hash,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );
    }

    function test_Deposit() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);

        vm.expectEmit(true, true, true, true);
        emit SwapInitiated(0, userChainA, userChainB, 0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        tokenChainB.approve(address(contractChainB), 1000);

        vm.expectEmit(true, true, true, true);
        emit SwapInitiated(0, userChainB, userChainA, 0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa);
        contractChainB.deposit(
            userChainA,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

    }

    function test_GetSwapInformation() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        AtomicSwap.Swap memory swap = contractChainA.getSwapInformation(
            0
        );
        assertEq(swap.sender, userChainA);
        assertEq(swap.recipient, userChainB);
        assertEq(swap.createdTime, block.timestamp);
        assertEq(swap.duration, 300);
        assertEq(swap.amount, 1000);
        assertEq(
            swap.hash,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );
        assertEq(swap.finished, false);
    }

    function test_Withdraw() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        tokenChainB.approve(address(contractChainB), 1000);
        contractChainB.deposit(
            userChainA,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainA);

        vm.expectEmit(true, true, true, true);
        emit SwapSuccessful(0, bytes("complex password"));
        contractChainA.withdraw(0, bytes("complex password"));
    }

    function test_CancelSwap() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        tokenChainB.approve(address(contractChainB), 1000);
        contractChainB.deposit(
            userChainA,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        vm.warp(block.timestamp + 301);
        changePrank(userChainA);

        vm.expectEmit(true, true, true, true);
        emit SwapCanceled(0);
        contractChainA.cancelSwap(0);
    }

    function test_CancelSwapNotExpired() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        vm.expectRevert(bytes("Not expired"));
        contractChainA.cancelSwap(0);
    }

    function test_CancelSwapAlreadyFinished() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        contractChainA.withdraw(0, bytes("complex password"));

        vm.warp(block.timestamp + 301);

        changePrank(userChainA);
        vm.expectRevert(bytes("Swap already finished"));
        contractChainA.cancelSwap(0);
    }

    function test_WithdrawAlreadyFinished() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        contractChainA.withdraw(0, bytes("complex password"));

        vm.expectRevert(bytes("Swap already finished"));
        contractChainA.withdraw(0, bytes("complex password"));
    }

    function test_WithdrawWrongPassword() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        changePrank(userChainB);
        vm.expectRevert(bytes("Wrong password!"));
        contractChainA.withdraw(0, bytes("complex"));
    }

    function test_WithdrawSwapExpired() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);
        contractChainA.deposit(
            userChainB,
            1000,
            300,
            0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa
        );

        vm.warp(block.timestamp + 301);

        changePrank(userChainB);
        vm.expectRevert(bytes("Swap expired"));
        contractChainA.withdraw(0, bytes("complex password"));
    }
}