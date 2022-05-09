
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.getBalance()).toString());

  const Ballot = await hre.ethers.getContractFactory("Ballot");
  const ballot = await Ballot.deploy();

  await ballot.deployed();

  console.log("ballot deployed to:", ballot.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
