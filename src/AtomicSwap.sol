// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin/token/ERC20/ERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "upgrades/Initializable.sol";

contract AtomicSwap is Initializable {
    using SafeERC20 for IERC20;

    struct Swap {
        address sender;
        address recipient;
        uint256 createdTime;
        uint256 duration;
        uint256 amount;
        bytes32 hash;
        bool finished;
    }

    IERC20 token;
    Swap[] swaps;

    event SwapInitiated(
        uint256 indexed id,
        address from,
        address to,
        bytes32 hash
    );
    event SwapSuccessful(uint256 indexed id, bytes password);
    event SwapCanceled(uint256 indexed id);

    function initialize(IERC20 tokenAddress) public initializer {
        token = tokenAddress;
    }

    function getSwapTokenAddress() external view returns (address) {
        return address(token);
    }

    function getSwapInformation(
        uint256 _id
    ) external view returns (Swap memory) {
        return swaps[_id];
    }

    function makeHash(string memory _password) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_password));
    }

    function deposit(
        address _recipient,
        uint256 _amount,
        uint256 _duration,
        bytes32 _hash
    ) external {
        Swap memory swap = Swap(
            msg.sender,
            _recipient,
            block.timestamp,
            _duration,
            _amount,
            _hash,
            false
        );
        swaps.push(swap);
        token.safeTransferFrom(msg.sender, address(this), _amount);

        emit SwapInitiated(swaps.length - 1, msg.sender, _recipient, _hash);
    }

    function withdraw(uint256 _id, bytes memory _password) external {
        Swap storage swap = swaps[_id];
        require(!swap.finished, "Swap already finished");
        require(swap.hash == keccak256(_password), "Wrong password!");
        require(
            swap.createdTime + swap.duration >= block.timestamp,
            "Swap expired"
        );

        swap.finished = true;
        token.safeTransfer(swap.recipient, swap.amount);

        emit SwapSuccessful(_id, _password);
    }

    function cancelSwap(uint256 _id) external {
        Swap storage swap = swaps[_id];
        require(
            swap.createdTime + swap.duration < block.timestamp,
            "Not expired"
        );
        require(!swap.finished, "Swap already finished");

        token.safeTransfer(swap.sender, swap.amount);

        emit SwapCanceled(_id);
    }
}
