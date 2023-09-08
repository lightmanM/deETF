// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract zkAutoDemo {
    uint256 private counter;

    event eventTriggered(uint256 indexed counter, uint256 counterRep);

    constructor() {
        counter = 0;
    }

    function run() public {
        counter += 1;
    }

    function triggerEvent() public {
        emit eventTriggered(counter, counter);
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
}