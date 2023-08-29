// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "./interface/IDemoVault.sol";

// simple ETF smart contract for testing hyper oracle workflow
contract HyperETF is ERC20 {
    address payable public owner;
    address public graphContract;
    address public demoVaultContract;

    address public token1;
    address public token2;

    uint256 public position1;
    uint256 public position2;

    // for ratio calculation
    uint256 public DECIMALBASE = 10000;
    uint256 public threshold = 100; // 1%
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    event migrateSuc(address indexed user, uint256 indexed etfTokenAmount);
    event redeemSuc(address indexed user, uint256 indexed etfTokenAmount);
    event reBalanceSuc(uint256 indexed position1, uint256 indexed position2);

    constructor(
        address[] memory asset,
        uint256[] memory positions,
        string memory _name,
        string memory _symbol) ERC20(_name, _symbol) payable {
        token1 = asset[0];
        token2 = asset[1];
        position1 = positions[0];
        position2 = positions[1];
        owner = payable(msg.sender);
    }

    function setGraphContract(address graphContractAddress) public {
        require(msg.sender == owner, "only owner can set graph contract");
        graphContract = graphContractAddress;
    }

    function setDemoVaultContract(address _demoVaultContract) public {
        require(msg.sender == owner, "only owner can set demo vault contract");
        demoVaultContract = _demoVaultContract;
        IERC20(token1).approve(address(_demoVaultContract), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        IERC20(token2).approve(address(_demoVaultContract), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function migrate(uint256 etfAmount) public {
        IERC20(token1).transferFrom(msg.sender, address(this), etfAmount * position1);
        IERC20(token2).transferFrom(msg.sender, address(this), etfAmount * position2);
        _mint(msg.sender, etfAmount);

        emit migrateSuc(msg.sender, etfAmount);
    }

    function redeem(uint256 etfAmount) public {
        require(balanceOf(msg.sender) > etfAmount, "insufficient fund");

        _burn(msg.sender, etfAmount);
        IERC20(token1).transfer(msg.sender, etfAmount * position1);
        IERC20(token2).transfer(msg.sender, etfAmount * position2);

        emit redeemSuc(msg.sender, etfAmount);
    }

    function reBalance(uint256 token1ToToken2Ratio) public {
        require(msg.sender == graphContract, "only graph contract can call this function");

        uint256 currTokenRatio = IERC20(token1).balanceOf(address(this)) * DECIMALBASE / IERC20(token2).balanceOf(address(this));

        // Ensure the provided ratio is within the threshold
        require(currTokenRatio > token1ToToken2Ratio ?
            currTokenRatio - token1ToToken2Ratio > threshold
            : token1ToToken2Ratio - currTokenRatio > threshold,
            "ratio diff is less than threshold");

        uint256 etfTotalSupply = totalSupply();
        uint256 halfAmountToSwap;

        // Compare current ratio to the provided ratio to see if the difference is greater than the threshold
        if (currTokenRatio > token1ToToken2Ratio) {
            // Calculate the amount of token1 to be swapped to token2
            halfAmountToSwap = ((currTokenRatio - token1ToToken2Ratio) * position2 * etfTotalSupply) / (2 * DECIMALBASE);

            // Ensure there is enough token1 for the swap
            require(IERC20(token1).balanceOf(address(this)) >= halfAmountToSwap, "Insufficient token1 balance for swap");

            // Perform the swap using DemoVault
            IDemoVault(demoVaultContract).swapToken1(halfAmountToSwap, halfAmountToSwap * token1ToToken2Ratio / DECIMALBASE);
        } else if (currTokenRatio < token1ToToken2Ratio) {
            // Calculate the amount of token2 to be swapped to token1
            halfAmountToSwap = ((token1ToToken2Ratio - currTokenRatio) * position1 * etfTotalSupply) / (2 * DECIMALBASE);

            // Ensure there is enough token2 for the swap
            require(IERC20(token2).balanceOf(address(this)) >= halfAmountToSwap, "Insufficient token2 balance for swap");

            // Perform the swap using DemoVault
            IDemoVault(demoVaultContract).swapToken2(halfAmountToSwap, halfAmountToSwap * DECIMALBASE / token1ToToken2Ratio);

        }
        position1 = IERC20(token1).balanceOf(address(this)) / etfTotalSupply;
        position2 = IERC20(token2).balanceOf(address(this)) / etfTotalSupply;

        emit reBalanceSuc(position1, position2);

    }
}
