// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin/token/ERC20/ERC20.sol";

contract SwapToken is ERC20 {
    constructor() ERC20("SwapToken", "SWT") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}
