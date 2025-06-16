# SnailBridge

SnailBridge is a lightweight cross-chain bridge for a minimal ERC-20 token called SNAIL. It allows users to seamlessly transfer SNAIL tokens between Sepolia and Base Sepolia test networks using Chainlink's CCIP (Cross-Chain Interoperability Protocol). Built for simplicity and experimentation, SnailBridge showcases a clean and minimal implementation of token bridging across EVM-compatible chains.

## 🐌 Getting Started

Deploy your own **SNAIL** token and bridge it between **Sepolia** and **Base Sepolia** using Chainlink CCIP.

---

### ⚙️ Setup

```sh
# Copy and configure environment variables
cp .env.example .env
cp web3/.env.example web3/.env
```

### 📦 Install & Test

```sh
make install      # Install dependencies
make test         # Run tests
```

### 🚀 Deploy & Configure

```sh
# Deploy to Sepolia and Base Sepolia
make deploy-eth-sepolia
make deploy-base-sepolia

# Configure CCIP on both chains
make configure-eth-sepolia
make configure-base-sepolia
```

### 🌉 Run the Web App

```sh
cd web3
pnpm install
pnpm run dev
```

Then open http://localhost:5173 in your browser.

## Already deployed contratcs

[eth-sepolia](https://sepolia.etherscan.io/)

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

- Could improve UI
- Could improve test coverage for run() methods in each script contract
- Could improve the Makefile
