// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 0xbbfd29475e4ef5bfb42bff4490d37caed5c88322
contract zkAutoDemo {
    uint256 private counter;

    constructor() {
        counter = 0;
    }

    function run() public {
        counter += 1;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }
}