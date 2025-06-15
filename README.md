# Cross-chain Token

## Contratc addresses

[eht-sepolia](https://sepolia.etherscan.io/)

- snailToken: `0xfdf3B1C58cd5231a796027E64b266517D702885D`
- snailTokenPool: `0xd9D667AC3621EC97B557C0eC7D11c3A854c4191d`

[base-sepolia](https://sepolia.basescan.org/)

- snailToken: `0xaF2E68f7bA08D0C249A922d68D999cbb245162db`
- snailTokenPool: `0x4A31740b841F707B40a9f880E575Bb1Ef47fB81a`

## Useful commands

```sh
# create a file to verify a contract on etherscan
forge verify-contract {contractAddress} {path}:{contract} \
--rpc-url {url} \
--etherscan-api-key {key} \
--show-standard-json-input > {file.json}
```

## TODO

- recheck `make install` and remappings.txt
- Could improve the Makefile
