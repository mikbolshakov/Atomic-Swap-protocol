// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {AtomicSwap} from "../src/AtomicSwap.sol";

contract AtomicSwapScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new AtomicSwap(IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7));
    }
}