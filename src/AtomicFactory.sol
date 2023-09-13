// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin/access/Ownable.sol";
import "./AtomicSwap.sol";

contract AtomicFactory is Ownable {
    address[] swapTokens;

    event NewAtomicSwapContract(address indexed atomicSwapAddress);

    function getSwapTokenAddress(uint256 _id) external view returns (address) {
        return swapTokens[_id];
    }

    function deployAtomic(IERC20 _swapToken) external onlyOwner {
        bytes32 salt = keccak256(abi.encodePacked(_swapToken));
        address atomicSwapAddress;
        atomicSwapAddress = address(new AtomicSwap{salt: salt}());

        AtomicSwap(atomicSwapAddress).initialize(_swapToken);
        swapTokens.push(atomicSwapAddress);

        emit NewAtomicSwapContract(atomicSwapAddress);
    }
}
