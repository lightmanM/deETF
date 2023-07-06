pragma solidity ^0.8.19;

contract BlackScholes {

    uint256 public C;

    /**
     * @dev calculateC calculates the call option price
     * @dev for precision into decimals the number must first
     * @dev be multiplied by the precision factor desired
     * @param S current stock price
     * @param K strike price
     * @param t time to maturity (in block timestamp)
     * @param r interest rate
     * @param vol volatility
     */
    function calculateC(
        //uint256[] memory _priceHistory,
        uint256 S,
        uint256 K,
        uint256 t,
        uint256 r,
        uint256 vol
    ) public returns (uint256) {
        C = blackScholesEstimate(S, K, t, r, vol);
        return C;
    }

    /**
     * @dev blackScholesEstimate calculates the call option price using the Black-Scholes-Merton model
     * @param S current stock price
     * @param K the strike price
     * @param t time to maturity (in block timestamp)
     * @param r risk-free interest rate
     * @param vol volatility of the underlying asset
     */
    function blackScholesEstimate(
        uint256 S,
        uint256 K,
        uint256 t,
        uint256 r,
        uint256 vol
    ) internal pure returns (uint256) {
        uint256 d1 = (log(S) - log(K) + ((r + ((vol * vol) / 2)) * t)) / (vol * sqrt(t));
        uint256 d2 = d1 - vol * sqrt(t);

        uint256 N_d1 = cumulativeNormalDistribution(d1);
        uint256 N_d2 = cumulativeNormalDistribution(d2);

        uint256 callPrice = (S * N_d1) - (exp(negate(r) * t) * N_d2);

        return callPrice;
    }

    /**
     * @dev sqrt calculates the square root of a given number x
     * @dev for precision into decimals the number must first
     * @dev be multiplied by the precision factor desired
     * @param _x uint256 number for the calculation of square root
     */
    function sqrt(uint256 _x) public pure returns (uint256) {
        int256 x = int256(_x);
        int256 c = (x + 1) / 2;
        int256 b = x;
        while (c < b) {
            b = c;
            c = (x / c + c) / 2;
        }
        return uint256(b);
    }

    /**
     * @dev stddev calculates the standard deviation for an array of integers
     * @dev precision is the same as sqrt above meaning for higher precision
     * @dev the decimal place must be moved prior to passing the params
     * @param numbers uint[] array of numbers to be used in calculation
     */
    function stddev(uint256[] memory numbers) public pure returns (uint256 sd) {
        require(numbers.length > 0, "Empty array");

        uint256 sum = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }
        uint256 mean = sum / numbers.length;

        sum = 0;
        for (uint256 i = 0; i < numbers.length; i++) {
            int256 diff = int256(numbers[i]) - int256(mean);
            sum += uint256(diff * diff);
        }

        sd = sqrt(sum / numbers.length);
        return sd;
    }

    /**
     * @dev log is the simple implementation of logarithm function
     * @param x the number to be used in calculation
     */
    function log(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;
        uint256 s = x - 1;
        for (uint256 i = 1; i <= 10; i++) {
            res += (s / i) * ((x - 1) / x) ** i;
            s *= (x - 1);
        }
        return res;
    }

    function exp(uint256 x) internal pure returns (uint256) {
        uint256 res = 0;
        for (uint256 i = 0; i <= 10; i++) {
            res += (x ** i) / factorial(i);
        }
        return res;
    }

    function factorial(uint256 n) internal pure returns (uint256) {
        uint256 res = 1;
        for (uint256 i = 2; i <= n; i++) {
            res *= i;
        }
        return res;
    }

    function negate(uint256 x) internal pure returns (uint256) {
        return 0 - x;
    }

    /**
     * @dev a simple cdf for current demo, of course this should be updated base on the stock prices.
     * @param x the number to be used in calculation
     */
    function cumulativeNormalDistribution(uint256 x) internal pure returns (uint256) {
        int256 t = int256(x);
        int256 b1 = 13931 * 10;
        int256 b2 = 33768 * 10;
        int256 b3 = 39734 * 10;
        int256 b4 = 25137 * 10;
        int256 b5 = 7667 * 10;
        int256 one = 10**18;

        int256 y = (one * t) / (one + (b1 * t / (one + (b2 * t / (one + (b3 * t / (one + (b4 * t / (one + (b5 * t / one))))))))));

        return uint256(y) * 10;
    }
}