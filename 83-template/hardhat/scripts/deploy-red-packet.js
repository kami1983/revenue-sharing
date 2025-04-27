const hre = require("hardhat");

async function main() {
  console.log("Deploying RedPacket contract...");
  
  // Deploy the RedPacket contract
  const RedPacket = await hre.ethers.getContractFactory("RedPacket");
  const redPacket = await RedPacket.deploy();
  
  await redPacket.deployed();
  
  console.log(`RedPacket contract deployed to: ${redPacket.address}`);
  console.log("Deployment completed successfully!");
  
  // Get the deployer's address
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Deployed by: ${deployer.address}`);
  
  // Display the contract owner
  console.log(`Contract owner: ${await redPacket.owner()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:");
    console.error(error);
    process.exit(1);
  }); 