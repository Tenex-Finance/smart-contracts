# Hardhat Deployment Instructions

Hardhat support was included as a way to provide an easy way to test the contracts on Tenderly with contract verification. 

## Set Up

1. Create a new fork on Tenderly. Once you have the fork, copy the fork id number (the component after `/fork`/ in the URL) and set it as your `TENDERLY_FORK_ID` in the `.env` file. The other fields that must be set include `PRIVATE_KEY_DEPLOY`, set to a private key used for testing.
2. Install packages via `npm install` or `yarn install`.
3. Follow the instructions of the [tenderly hardhat package](https://github.com/Tenderly/hardhat-tenderly/tree/master/packages/tenderly-hardhat) to install the tenderly cli and login.

## Deployment

1. Deploy the Tenex contracts:

`npx hardhat run script/hardhat/DeployTenex.ts --network tenderly`

The contracts that were deployed will be saved in `script/constants/output/TenexOutput.json`. 

2. Deploy V2 pools and create gauges for them.

`npx hardhat run script/hardhat/DeployGaugesAndPoolsV2.ts --network tenderly`

3. Deploy Governors. You will need to set the governors manually in tenderly.

`npx hardhat run script/hardhat/DeployGovernors.ts --network tenderly`

Governor deployed to: 0x3Ca6377f7003193cC5B3797C3Bc411C858C7D8B0
EpochGovernor deployed to: 0x45B7275b7B53A817F23f098BD888c9a2B41Ab9e7

Blast Sepolia with tenex :

Governor deployed to: 0x6281658001604C3c5Bed5390e7B218EB543Fe125
EpochGovernor deployed to: 0xBa5ADeB9ae6098DFB1F8E461276B833E0BbEA3ED
