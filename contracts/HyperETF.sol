// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// simple ETF smart contract for testing hyper oracle workflow
contract HyperETF {
    address payable public owner;
    address public token1;
    address public token2;
    address public baseToken;

    event Withdrawal(uint256 balance, uint256 blocktime);

    constructor(address _token1, address _token2, address _baseToken) payable {
        token1 = _token1;
        token2 = _token2;
        baseToken = _baseToken;
        owner = payable(msg.sender);
    }

    function withdraw() public {
        // Uncomment this line, and the import of "hardhat/console.sol", to print a log in your terminal
        // console.log(block.timestamp);

        require(msg.sender == owner, "You aren't the owner");

        emit Withdrawal(address(this).balance, block.timestamp);

        owner.transfer(address(this).balance);
    }
}
