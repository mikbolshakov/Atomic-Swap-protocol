// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error NotAnOwner(address initiator);

contract Wallet {
    address public owner;

    uint256 public lastDepositAt;
    uint256 private constant DELAY = 120;

    event Deposited(uint256 indexed amount, address sender);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotAnOwner(msg.sender);
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable onlyOwner {
        require(msg.value > 0, "wrong sum!");
        lastDepositAt = block.timestamp;
        emit Deposited(msg.value, msg.sender);
    }

    function withdraw() external onlyOwner {
        require(getBalance() > 0 && lastDepositAt > 0, "nothing was deposited!");
        require(block.timestamp > lastDepositAt, "too early");
        payable(msg.sender).transfer(getBalance());
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable onlyOwner {
        deposit();
    }
}
