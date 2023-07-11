// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PRBMathSD59x18} from "./PRBMathSD59x18.sol";

contract BlackScholes {
    using PRBMathSD59x18 for int256;

    uint256 private constant SCALE = 1e18; // Scaling factor for PRBMathSD59x18
    uint256 private constant RANGE = 10; // Range of the distribution
    uint256 private constant MIDPOINT = 5; // Middle point of the distribution

    int256 public C;
    function calculateCallOptionPrice(
        int256 S,
        int256 K,
        int256 T,
        int256 sigma, //vol
        int256 r
    )
    public
    returns (int256)
    {
        // Calculate the components of the Black-Scholes formula
        int256 d1 = calculateD1(S, K, T, sigma, r);
        int256 d2 = calculateD2(d1, sigma, T);
        int256 cumulativeD1 = calculateCumulativeNormalDistribution(d1);
        int256 cumulativeD2 = calculateCumulativeNormalDistribution(d2);

        // Calculate call option price
        int256 callPrice = calculateCallPrice(S, cumulativeD1, K, cumulativeD2, T, r);
        C = callPrice;
        return callPrice;
    }

    function calculateD1(
        int256 S,
        int256 K,
        int256 T,
        int256 sigma,
        int256 r
    )
    public
    returns (int256)
    {
        int256 sqrtT = PRBMathSD59x18.sqrt(T);
        int256 lnS = PRBMathSD59x18.ln(S);
        int256 lnK = PRBMathSD59x18.ln(K);
        int256 d1Numerator1 = lnS - lnK;
        int256 d1Numerator2 = PRBMathSD59x18.powu(sigma, 2);
        d1Numerator2 = PRBMathSD59x18.div(d1Numerator2, 2e18);
        int256 d1Numerator3 = r + d1Numerator2;
        int256 d1Numerator4 = PRBMathSD59x18.mul(d1Numerator3, T);
        int256 d1Numerator = d1Numerator1 + d1Numerator4;

        int256 d1Denominator = PRBMathSD59x18.mul(sigma, sqrtT);
        int256 d1 = PRBMathSD59x18.div(d1Numerator, d1Denominator);
        return d1;
    }

    function calculateD2(int256 d1, int256 sigma, int256 T) internal pure returns (int256) {
        int256 sqrtT = PRBMathSD59x18.sqrt(T);
        int256 toBeSubs = sigma.mul(sqrtT);
        int256 d2 = d1 - toBeSubs;
        return d2;
    }

    // need a erf function
    function calculateCumulativeNormalDistribution(int256 x) internal pure returns (int256) {
        //simple implementation
        if(x < 0) {
            return 0;
        }
        int256 sdX = PRBMathSD59x18.mul(x, PRBMathSD59x18.scale());
        int256 sdRange = PRBMathSD59x18.mul(int256(RANGE), PRBMathSD59x18.scale());

        return PRBMathSD59x18.div(sdX, sdRange);
    }


    function calculateCallPrice(
        int256 S,
        int256 cumulativeD1,
        int256 K,
        int256 cumulativeD2,
        int256 T,
        int256 r
    )
    internal
    pure
    returns (int256)
    {
        int256 discountedS = PRBMathSD59x18.mul(S, cumulativeD1);
        int256 discountedK1 = PRBMathSD59x18.mul(K, cumulativeD2);
        int256 RT = PRBMathSD59x18.mul(r, T);
        int256 negateRT = -RT;
        int256 expERT = PRBMathSD59x18.exp(negateRT);
        int256 discountedK2 = PRBMathSD59x18.mul(discountedK1, expERT);
        int256 callPrice = discountedS - discountedK2;
        return callPrice;
    }
}
