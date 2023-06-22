// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';

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
    address public uniswapRouter;

    event investSuc(address indexed user, uint256 indexed etefTokenAmount);
    event migrateSuc(address indexed user, uint256 indexed etfTokenAmount);
    event redeemSuc(address indexed user, uint256 indexed etfTokenAmount);
    event reBalanceSuc(address indexed tokenFrom, address indexed tokenTo, uint256 amount);

    modifier onlyzkAuto() {
        require(msg.sender == zkAuto);
        _;
    }

    constructor(
        address[] memory asset,
        uint256[] memory positions,
        address _baseToken,
        address _zkAuto,
        address _uniswapRouter,
        string memory _name,
        string memory _symbol) ERC20(_name, _symbol) payable {
        token1 = asset[0];
        token2 = asset[1];
        position1 = positions[0];
        position2 = positions[1];
        baseToken = _baseToken;
        zkAuto = _zkAuto;
        uniswapRouter = _uniswapRouter;
        owner = payable(msg.sender);
    }

    function invest(address _token, uint256 etfAmount) public {
        uint256 amountToSwap1 = etfAmount * position1;
        uint256 amountToSwap2 = etfAmount * position2;
        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = token1;
        IUniswapV2Router01(uniswapRouter).swapTokensForExactTokens(amountToSwap1, type(uint256).max, path, address(this), block.timestamp + 100);
        path[1] = token2;
        IUniswapV2Router01(uniswapRouter).swapTokensForExactTokens(amountToSwap2, type(uint256).max, path, address(this), block.timestamp + 100);

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

        emit redeemSuc(msg.sender, etfAmount);
    }

    //assume this part should be controlled by hyper oracle?
    function reBalance(bool zeroOrOne, uint256 amountToSwap) public onlyzkAuto {
        address tokenFrom = zeroOrOne ? token1: token2;
        address tokenTo = zeroOrOne ? token2: token1;
        address[] memory path = new address[](2);
        path[0] = tokenFrom;
        path[1] = tokenTo;

        // a naive swap without considering any other transfer activity/slippage
        IUniswapV2Router01(uniswapRouter).swapTokensForExactTokens(amountToSwap, type(uint256).max, path, address(this), block.timestamp + 100);
        position1 = IERC20(token1).balanceOf(address(this));
        position2 = IERC20(token2).balanceOf(address(this));

        emit reBalanceSuc(tokenFrom, tokenTo, amountToSwap);
    }
}
