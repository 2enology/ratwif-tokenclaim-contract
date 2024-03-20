# RatWifHat-Claim-Contract-eth

## How to deploy the contract

npx hardhat run scripts/deploy_tokenAirdrop.js --network flaretest

## How to verify the contract

npx hardhat verify --network flaretest DEPLOYED_CONTRACT_ADDRESS "Constructor argument 1" "Constructor argument 2" ...
