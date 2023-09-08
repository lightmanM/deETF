// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "./interface/IDemoVault.sol";

// simple ETF smart contract for testing hyper oracle workflow
contract dETF is ERC20 {
    address public owner;
    address public graphContract;
    address public demoVaultContract;

    address public token1;
    address public token2;

    uint256 public position1;
    uint256 public position2;

    // for ratio calculation
    uint256 immutable public DECIMALBASE = 1e18;
    uint256 MAX_INT = ~uint256(0);

    event investSuc(address indexed user, uint256 indexed etfTokenAmount);
    event redeemSuc(address indexed user, uint256 indexed etfTokenAmount);
    event reBalanceSuc(uint256 indexed position1, uint256 indexed position2);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this function");
        _;
    }

    modifier onlyGraph() {
        require(msg.sender == graphContract, "only graph can call this function");
        _;
    }

    constructor(
        address[] memory asset,
        uint256[] memory positions,
        string memory _name,
        string memory _symbol) ERC20(_name, _symbol) {
        token1 = asset[0];
        token2 = asset[1];
        position1 = positions[0];
        position2 = positions[1];
        owner = msg.sender;
    }

    function setGraphContract(address graphContractAddress) public onlyOwner {
        graphContract = graphContractAddress;
    }

    function setDemoVaultContract(address _demoVaultContract) public onlyOwner {
        demoVaultContract = _demoVaultContract;
        IERC20(token1).approve(address(_demoVaultContract), MAX_INT);
        IERC20(token2).approve(address(_demoVaultContract), MAX_INT);
    }

    function invest(uint256 etfAmount) public {
        IERC20(token1).transferFrom(msg.sender, address(this), etfAmount * position1 / DECIMALBASE);
        IERC20(token2).transferFrom(msg.sender, address(this), etfAmount * position2 / DECIMALBASE);
        _mint(msg.sender, etfAmount);

        emit investSuc(msg.sender, etfAmount);
    }

    function redeem(uint256 etfAmount) public {
        require(balanceOf(msg.sender) > etfAmount, "insufficient fund");

        _burn(msg.sender, etfAmount);
        IERC20(token1).transfer(msg.sender, etfAmount * position1);
        IERC20(token2).transfer(msg.sender, etfAmount * position2);

        emit redeemSuc(msg.sender, etfAmount);
    }

    function rebalance(uint256 price) public onlyGraph {
        uint256 currTokenRatio = IERC20(token1).balanceOf(address(this)) * DECIMALBASE / IERC20(token2).balanceOf(address(this));

        uint256 etfTotalSupply = totalSupply();
        uint256 halfAmountToSwap;

        // Compare current ratio to the provided ratio to see if the difference is greater than the threshold
        if (currTokenRatio > price) {
            // Calculate the amount of token1 to be swapped to token2
            halfAmountToSwap = ((currTokenRatio - price) * position2 * etfTotalSupply) / (2 * DECIMALBASE);

            // Ensure there is enough token1 for the swap
            require(IERC20(token1).balanceOf(address(this)) >= halfAmountToSwap, "Insufficient token1 balance for swap");

            // Perform the swap using DemoVault
            IDemoVault(demoVaultContract).swapToken1(halfAmountToSwap, halfAmountToSwap * price / DECIMALBASE);
        } else if (currTokenRatio < price) {
            // Calculate the amount of token2 to be swapped to token1
            halfAmountToSwap = ((price - currTokenRatio) * position1 * etfTotalSupply) / (2 * DECIMALBASE);

            // Ensure there is enough token2 for the swap
            require(IERC20(token2).balanceOf(address(this)) >= halfAmountToSwap, "Insufficient token2 balance for swap");

            // Perform the swap using DemoVault
            IDemoVault(demoVaultContract).swapToken2(halfAmountToSwap, halfAmountToSwap * DECIMALBASE / price);

        }
        position1 = IERC20(token1).balanceOf(address(this)) / etfTotalSupply * DECIMALBASE;
        position2 = IERC20(token2).balanceOf(address(this)) / etfTotalSupply * DECIMALBASE;

        emit reBalanceSuc(position1, position2);

    }
}
