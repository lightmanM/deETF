import { ethers } from "hardhat";

async function main() {
  // Step 1: Deploy WBTC and WETH MintableTokens
  console.log("Starting Deployment");
  const zkAutoDemo = await ethers.getContractFactory("zkAutoDemo");
  // const zkAutoDemoContract = await zkAutoDemo.deploy();
  //
  // await zkAutoDemoContract.waitForDeployment();
  const zkAutoDemoContract = zkAutoDemo.attach("0x362b63b77448C2ffBC03511FE100fCd3d879795F");
  console.log("zkAutoDemo deployed to:", await zkAutoDemoContract.getAddress());
  // Other logic, if needed
  while (true) {
    await zkAutoDemoContract.triggerEvent();
    console.log("trigger Event");
    console.log("zkAutoDemo Counter: ", await zkAutoDemoContract.getCounter());
    await new Promise(resolve => setTimeout(resolve, 15000));
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
