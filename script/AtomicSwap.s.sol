// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {AtomicSwap} from "../src/AtomicSwap.sol";

contract AtomicSwapScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new AtomicSwap();
    }
}
