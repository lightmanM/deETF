import "./interface/IDemoVault.sol";
import "./interface/IMintableToken.sol";

contract DemoVault is IDemoVault {
    IMintableToken public token1;
    IMintableToken public token2;

    constructor(address _token1, address _token2) {
        require(_token1 != _token2, "Token addresses must be different");

        token1 = IMintableToken(_token1);
        token2 = IMintableToken(_token2);
    }

    // Deposit and mint tokens into the vault
    function deposit(address tokenAddress, uint256 amount) external {
        IMintableToken token = (tokenAddress == address(token1)) ? token1 : token2;

        // Mint tokens and deposit them into the vault (DemoVault)
        token.mint(address(this), amount);
    }

    function claim(address tokenAddress, uint256 amount) external {
        IMintableToken token = (tokenAddress == address(token1)) ? token1 : token2;

        // Mint tokens and deposit them into the vault (DemoVault)
        token.transferFrom(address(this), msg.sender, amount);
    }

    // Swap from token1 to token2
    function swapToken1(uint256 amountIn, uint256 amountOut) external {
        require(token1.transferFrom(msg.sender, address(this), amountIn), "Transfer of token1 failed");
        require(token2.transfer(msg.sender, amountOut), "Transfer of token2 failed");
    }

    // Swap from token2 to token1
    function swapToken2(uint256 amountIn, uint256 amountOut) external {
        require(token2.transferFrom(msg.sender, address(this), amountIn), "Transfer of token2 failed");
        require(token1.transfer(msg.sender, amountOut), "Transfer of token1 failed");
    }
}