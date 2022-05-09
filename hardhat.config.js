require("@nomiclabs/hardhat-waffle");
require('solidity-coverage');
//require('dotenv').config({ path: require('find-config')('.env') })

const provider = process.env.WEB3_PROVIDER;

 const account = process.env.PRIVATE_KEY;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat:{},
    ropsten: {
      url: "https://ropsten.infura.io/v3/aeedeee14fbb4381835dddba25acfa41",
      accounts: ['0xad864022b73050b6f672a687002d07fae0f94176534577a1bf61bd24fe12b43a'],
    }
  }
};
