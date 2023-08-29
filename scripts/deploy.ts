import { ethers } from "hardhat";

async function main() {
  // Step 1: Deploy WBTC and WETH MintableTokens
  console.log("Starting Deployment");
  const MintableToken = await ethers.getContractFactory("MintableToken");

  const wbtc = await MintableToken.deploy("Wrapped Bitcoin", "WBTC");
  await wbtc.waitForDeployment();
  const weth = await MintableToken.deploy("Wrapped Ether", "WETH");
  await weth.waitForDeployment();

  // after successful deployment
  // const wbtc = MintableToken.attach("0x4cB340BcB9f6313497fC623A9D127BE092a0f1Fa");
  const wbtcAddress = await wbtc.getAddress();
  // const weth = MintableToken.attach("0x1E2fe112a66aa43128b2292B6D2E580a62AED833");
  const wethAddress = await weth.getAddress();

  console.log(`WBTC deployed to: ${wbtcAddress}`);
  console.log(`WETH deployed to: ${wethAddress}`);

  // Step 2: Deploy DemoVault
  const DemoVault = await ethers.getContractFactory("DemoVault");
  const demoVault = await DemoVault.deploy(wbtcAddress, wethAddress);
  await demoVault.waitForDeployment();
  // const demoVault = DemoVault.attach("0x3FeFAca597b9A6BA87b032260D428E3F62D49358");
  const demoVaultAddress = await demoVault.getAddress();

  console.log(`DemoVault deployed to: ${demoVaultAddress}`);

  // Step 3: Deposit tokens into DemoVault
  const depositAmount = 1000000000000000000000000n;
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
