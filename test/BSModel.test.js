const { assert } = require('chai');
const { ethers } = require("hardhat");

describe('BSModel', () => {
    let blackScholes;
    let owner;
    let addr1;
    let addr2;

    before(async() => {
        // Deploy the BlackScholes contract
        const BlackScholes = await ethers.deployContract('BlackScholes');
        blackScholes = await BlackScholes.waitForDeployment();

        // Get signers from the Ethereum provider
        [owner, addr1, addr2] = await ethers.getSigners();
    });

    it("should calculate the call option price correctly", async () => {
        // Mock input parameters
        //const priceHistory = [150, 200, 210, 250, 300]; // Mock price history
        const S = 280; // Current stock price
        const t = 100; // Time to maturity
        const r = 1; // Risk-free interest rate
        const _vol = 100; // volatility
        // Call the calculateC function
        const C = await blackScholes.calculateC(S, t, r, _vol);
        assert.equal(await blackScholes.C(), 10); // Adjust the expected result based on your calculations

        // Assert the expected result
        assert.equal(await blackScholes.sqrt(100), 10); // Adjust the expected result based on your calculations
    });
});