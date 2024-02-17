![1500x500-3](https://github.com/fuzzland/ducks-contract/assets/10573715/b8745f33-2e79-4bf8-a27a-10e29f8f9fbd)
<label style="float:right">**Duck Contracts For BLAST**</label> 

### Testing
Run the following command to test the contracts:
```
forge test -vvvv
```


### Deploy

Run the following command to deploy the contracts and set the WETH address for BLAST network:
```
forge create src/Duck.sol:Duck --private-key ... --rpc-url https://sepolia.blast.io
cast send ... 'setWETH(address)' '0x4200000000000000000000000000000000000023' --rpc-url https://sepolia.blast.io  --private-key $PK
forge verify-contract ... src/Duck.sol:Duck --chain blast-sepolia --etherscan-api-key "verifyContract"
```


### Frontend

Run the following command to start the frontend:
```
cd frontend
pnpm install
pnpm run dev
```

Build the frontend:
```
pnpm run build
```