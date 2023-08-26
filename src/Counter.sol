// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
//     solc = '0.8.19'
// optimizer = true
// optimizer_runs = 200
// remappings = ["@openzeppelin/=node_modules/@openzeppelin/contracts"]

    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
