# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

Deploy & Verify:

```shell
npx hardhat compile
npx hardhat run scripts/{deploy_file_name}.js --network {network}
npx hardhat  verify --network {network} {smart_contract_address}  --contract contracts/{file_name}.sol:{smart_contract_name}
```

Example:

```shell
npx hardhat compile
npx hardhat run scripts/deploy.js --network testnet
npx hardhat verify --network testnet 0xe6a04f569843069B6eC37bB7515C806Fb2D6EAf3 --contract contracts/SuccessRate.sol:SuccessRate
```


