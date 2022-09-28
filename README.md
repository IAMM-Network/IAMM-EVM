# IAMM-EVM
Code repository of IAMM Libre NFTs for ETH Mexico Hackathon.

Libre NFTs is our philosophy to give the creators, developers, collectors and curators the freedom to generate value and get rewards for the value generated.

## Contracts 

Whe have 2 main repos for contract in `/contracts` directory.

### Identity

- ClaimHolder
- ClaimVerifier
- ERC725
- ERC735
- Identity
- KeyHolder

### Minting

- BEP20USDT
- ERC4907
- IAMM1155
- IERC4907
- MetaToken
- RentableIAMM

## Frontend
The frontend was builded with Typescript/TS and the following routes are available for testing.

Home directory when you can connect your **WalletConnect V2** 
rember to use these wallet for V2 compatibility.
```
/
```

These directory is used after you **WalletConnect V2** and in this page you will create your 
"Profile" base on ERC725.
```
/profile-dashboard
```

This is where the magic happens, you will create your awesome NFT with the MAX qty of features
and fully-customizable
```
/create-single-nft
```
