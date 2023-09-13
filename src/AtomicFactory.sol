// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./AtomicSwap.sol";

contract AtomicFactory {
    event NewAtomicSwapContract(address indexed atomicSwapAddress);

    function deployAtomic(address _swapToken) external {
        AtomicSwap atomic = new AtomicSwap(IERC20(_swapToken));

        emit NewAtomicSwapContract(address(atomic));
    }
}