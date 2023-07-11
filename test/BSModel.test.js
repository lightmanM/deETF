const { expect } = require('chai');
const { ethers } = require("hardhat");

describe('BSModel', () => {
    let BlackScholesCalculator;
    let blackScholesCalculator;
    let PRBMathSD59x18;
    let prbMathSD59x18;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async() => {
        // Deploy PRBMathSD59x18
        // PRBMathSD59x18 = await ethers.deployContract("PRBMathSD59x18");
        // prbMathSD59x18 = await PRBMathSD59x18.waitForDeployment();
        // , {
        //         libraries: {
        //             PRBMathSD59x18: prbMathSD59x18.target,
        //         },
        //     }
        // Deploy the BlackScholesCalculator contract, linking the library
        BlackScholesCalculator = await ethers.deployContract("BlackScholes");
        blackScholesCalculator = await BlackScholesCalculator.waitForDeployment();
    });

    it("should calculate the call option price correctly", async () => {
        const SCALE = 1000000000000000000n;
        // Define the example inputs (already scaled by 1e18)
        const S = 100n * SCALE;
        const K = 110n * SCALE;
        const T = 100n * SCALE;
        const sigma = 2n * SCALE;
        const r = SCALE / 100n; // 5%

        // Call the calculateCallOptionPrice function
        const callOptionPrice = await blackScholesCalculator.calculateCallOptionPrice(
            S,
            K,
            T,
            sigma,
            r
        );

        const result = await blackScholesCalculator.C();
        console.log(result);

        // Perform assertions on the calculated call option price
        // Adjust the expected result based on your specific calculations
        // Note: The output is in scaled format (scaled by 1e18)
        const expectedCallOptionPrice = 100452344910097837560n; // Adjust based on your specific calculations
        expect(result / SCALE).to.be.equal(expectedCallOptionPrice);
    });
});