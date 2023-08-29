// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDemoVault {
    function deposit(address tokenAddress, uint256 amount) external;
    function claim(address tokenAddress, uint256 amount) external;
    function swapToken1(uint256 amountIn, uint256 amountOut) external;
    function swapToken2(uint256 amountIn, uint256 amountOut) external;
}