const hre = require("hardhat");

async function main() {
  console.log("Deploying RedPacketLite contract...");
  
  // Deploy the RedPacketLite contract
  const RedPacketLite = await hre.ethers.getContractFactory("RedPacketLite");
  const redPacketLite = await RedPacketLite.deploy();
  
  await redPacketLite.deployed();
  
  console.log(`RedPacketLite contract deployed to: ${redPacketLite.address}`);
  console.log("Deployment completed successfully!");
  
  // Get the deployer's address
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deployed by: ${deployer.address}`);
  
  // Display the contract owner
  console.log(`Contract owner: ${await redPacketLite.owner()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:");
    console.error(error);
    process.exit(1);
  }); 