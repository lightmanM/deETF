import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("deployer address:", deployer.address);

  // Step 1: Deploy WBTC and WETH MintableTokens
  const MintableToken = await ethers.getContractFactory("MintableToken");
  const wbtc = await MintableToken.deploy("Wrapped Bitcoin", "WBTC");

  await wbtc.waitForDeployment();
  const weth = await MintableToken.deploy("Wrapped Ether", "WETH");
  await weth.waitForDeployment();

  const wbtcAddress = await wbtc.getAddress();
  const wethAddress = await weth.getAddress();

  console.log(`WBTC deployed to: ${wbtcAddress}`);
  console.log(`WETH deployed to: ${wethAddress}`);

  // Step 2: Deploy DemoVault
  const DemoVault = await ethers.getContractFactory("DemoVault");
  const demoVault = await DemoVault.deploy(wbtcAddress, wethAddress);
  await demoVault.waitForDeployment();
  const demoVaultAddress = await demoVault.getAddress();

  console.log(`DemoVault deployed to: ${demoVaultAddress}`);

  // Step 3: Deposit tokens into DemoVault
  const depositAmount = 10e24;
  await demoVault.deposit(wbtcAddress, depositAmount);
  await demoVault.deposit(wethAddress, depositAmount);

  console.log(`Deposited ${depositAmount} tokens of each kind into DemoVault`);

  // Step 4: Deploy HyperETF
  const HyperETF = await ethers.getContractFactory("HyperETF");
  const hyperETF = await HyperETF.deploy(
      [wbtcAddress, wethAddress],
      [100, 1000],
      "dETF Token",
      "dETF"
  );
  await hyperETF.waitForDeployment();
  const HyperETFAddress = await hyperETF.getAddress();

  console.log(`HyperETF deployed to: ${HyperETFAddress}`);

  // Other logic, if needed
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
