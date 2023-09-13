// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {AtomicFactory} from "../src/AtomicFactory.sol";
import {SwapToken} from "../src/SwapToken.sol";

contract AtomicFactoryTest is Test {
    AtomicFactory public factory;
    SwapToken public swapToken;

    function setUp() public {
        factory = new AtomicFactory();
        swapToken = new SwapToken();
    }

    function test_DeployAtomic() public {
        factory.deployAtomic(swapToken);

        address deployedAtomic = factory.getSwapTokenAddress(0);
        assertTrue(
            deployedAtomic != address(0),
            "Atomic contract not deployed"
        );
    }
}
