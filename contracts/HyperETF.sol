// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// simple ETF smart contract for testing hyper oracle workflow
contract HyperETF is ERC20 {
    address payable public owner;
    // for quick demo purpose
    address public token1;
    address public token2;

    uint256 public position1;
    uint256 public position2;

    address public baseToken; // for token swap
    address public zkAuto; // I suppose there should be another contract to invoke func here?

    event investSuc(address indexed user, uint256 indexed etefTokenAmount);
    event migrateSuc(address indexed user, uint256 indexed etfTokenAmount);
    event redeemSuc(address indexed user, uint256 indexed etfTokenAmount);
    event reBalanceSuc(address indexed user);

    modifier onlyzkAuto() {
        require(msg.sender == zkAuto);
        _;
    }

    constructor(address[] asset, uint256[] positions, address _baseToken, address _zkAuto) payable {
        token1 = asset[0];
        token2 = asset[1];
        baseToken = _baseToken;
        zkAuto = _zkAuto;
        owner = payable(msg.sender);
    }

    function invest(address _token, uint256 etfAmount) public {
        //

        emit investSuc(msg.sender, etfAmount);
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

        emit redeem(msg.sender, etfAmount);
    }

    function reBalance() public onlyzkAuto {

    }
}
