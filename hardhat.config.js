require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('@symblox/hardhat-abi-gen');


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// const { mnemonic, privateKey } = require('./secrets.json');
const fs = require('fs')
const privateKey = fs.readFileSync(".secret").toString().trim() || "01234567890123456789"
const apiKey = fs.readFileSync(".apiKey").toString().trim()
const apiKeyAlchemy = fs.readFileSync(".apiKeyAlchemy").toString().trim()

const forkURL = "https://eth-mainnet.alchemyapi.io/v2/" + apiKeyAlchemy



/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
   defaultNetwork: "hardhat",
   networks: {
   	localhost: {
       url: "http://127.0.0.1:8545"
     },
     hardhat: {
      fork: {
        url: forkURL
      }
     },
     testnet: {
       url: "https://data-seed-prebsc-1-s1.binance.org:8545",
       chainId: 97,
       gasPrice: 20000000000,
       accounts: [privateKey]
     }, 
     mainnet: {
       url: "https://bsc-dataseed.binance.org/",
       chainId: 56,
       gasPrice: 20000000000,
       accounts: [privateKey]
     },
     hardhat: {
      chainId: 1337
    }
   },
   etherscan: {
    apiKey: apiKey
   },
   solidity: {
   version: "0.8.7",
   settings: {
     optimizer: {
       enabled: true,
       runs: 1000,
     }
    }
   },
   paths: {
     sources: "./contracts",
     tests: "./test",
     cache: "./cache",
     artifacts: "./artifacts"
   },
   mocha: {
     timeout: 20000
   },
   abiExporter: {
    path: './data/abi',
    clear: true,
    flat: true,
    // only: [':ERC20$'],
    spacing: 2
  }
 };
