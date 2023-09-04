// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {MyToken} from "../src/Collection.sol";

contract CollectionTest is Test {
    MyToken public token;
    address public user = makeAddr("user");

    function setUp() public {
        token = new MyToken();
    }

    function test_Mint() public {
        uint256 lastToken = 2_500_000;
        for (uint i = 0; i < lastToken; i++) {
            vm.prank(user);
            token.safeMint(
                "dich dich dich dich",
                "dich dich dich dich",
                "dich dich dich dich",
                "dich dich dich dich"
            );
        }
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
