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
    bytes32 passwordHash =
        0x85dd02dce2325c2807c76f58c90a944de5527e1240e6babfd9a30099e6039faa;

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
        contractChainA = new AtomicSwap();
        contractChainA.initialize(tokenChainA);

        changePrank(userChainB);
        tokenChainB = new SwapToken();
        contractChainB = new AtomicSwap();
        contractChainB.initialize(tokenChainB);
    }

    function test_MakeHash() public {
        bytes32 hash = contractChainA.makeHash("complex password");
        assertEq(hash, passwordHash);
    }

    function test_GetSwapTokenAddress() public {
        address swapTokenAddress = contractChainA.getSwapTokenAddress();
        assertEq(swapTokenAddress, address(tokenChainA));
    }

    function test_Deposit() public {
        changePrank(userChainA);
        tokenChainA.approve(address(contractChainA), 10000);

        vm.expectEmit(true, true, true, true);
        emit SwapInitiated(0, userChainA, userChainB, passwordHash);
        contractChainA.deposit(userChainB, 1000, 300, passwordHash);

        changePrank(userChainB);
        tokenChainB.approve(address(contractChainB), 1000);

        vm.expectEmit(true, true, true, true);
        emit SwapInitiated(0, userChainB, userChainA, passwordHash);
        contractChainB.deposit(userChainA, 1000, 300, passwordHash);
    }

    function test_GetSwapInformation() public {
        test_Deposit();
        changePrank(userChainA);

        AtomicSwap.Swap memory swap = contractChainA.getSwapInformation(0);
        assertEq(swap.sender, userChainA);
        assertEq(swap.recipient, userChainB);
        assertEq(swap.createdTime, block.timestamp);
        assertEq(swap.duration, 300);
        assertEq(swap.amount, 1000);
        assertEq(swap.hash, passwordHash);
        assertEq(swap.finished, false);
    }

    function test_Withdraw() public {
        test_Deposit();

        vm.expectEmit(true, true, true, true);
        emit SwapSuccessful(0, bytes("complex password"));
        contractChainA.withdraw(0, bytes("complex password"));
    }

    function test_CancelSwap() public {
        test_Deposit();

        vm.warp(block.timestamp + 301);
        changePrank(userChainA);

        vm.expectEmit(true, true, true, true);
        emit SwapCanceled(0);
        contractChainA.cancelSwap(0);
    }

    function test_CancelSwapNotExpired() public {
        test_Deposit();
        changePrank(userChainA);

        vm.expectRevert(bytes("Not expired"));
        contractChainA.cancelSwap(0);
    }

    function test_CancelSwapAlreadyFinished() public {
        test_Deposit();
        contractChainA.withdraw(0, bytes("complex password"));

        vm.warp(block.timestamp + 301);

        changePrank(userChainA);
        vm.expectRevert(bytes("Swap already finished"));
        contractChainA.cancelSwap(0);
    }

    function test_WithdrawAlreadyFinished() public {
        test_Deposit();

        contractChainA.withdraw(0, bytes("complex password"));

        vm.expectRevert(bytes("Swap already finished"));
        contractChainA.withdraw(0, bytes("complex password"));
    }

    function test_WithdrawWrongPassword() public {
        test_Deposit();

        vm.expectRevert(bytes("Wrong password!"));
        contractChainA.withdraw(0, bytes("complex"));
    }

    function test_WithdrawSwapExpired() public {
        test_Deposit();

        vm.warp(block.timestamp + 301);

        vm.expectRevert(bytes("Swap expired"));
        contractChainA.withdraw(0, bytes("complex password"));
    }
}
