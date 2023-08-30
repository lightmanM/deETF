import { ethers } from "hardhat";

async function main() {
  // Step 1: Deploy WBTC and WETH MintableTokens
  console.log("Starting Deployment");
  const zkAutoDemo = await ethers.getContractFactory("zkAutoDemo");
  const zkAutoDemoContract = await zkAutoDemo.deploy();

  await zkAutoDemoContract.waitForDeployment();
  console.log("zkAutoDemo deployed to:", await zkAutoDemoContract.getAddress());
  // Other logic, if needed
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
