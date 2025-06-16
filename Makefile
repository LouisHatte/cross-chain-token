-include .env

.PHONY: install test coverage deploy-eth-sepolia deploy-base-sepolia configure-eth-sepolia configure-base-sepolia

install:
	forge install \
	smartcontractkit/chainlink@v2.24.0 \
	smartcontractkit/chainlink-local@v0.2.5 \
	foundry-rs/forge-std@v1.9.7 \
	OpenZeppelin/openzeppelin-contracts@v4.8.3

test:; @forge test

coverage:
	forge coverage --report lcov && \
	genhtml lcov.info --ignore-errors inconsistent --output-directory stats && \
	open stats/index.html

deploy-eth-sepolia:
	@forge script script/Deployer.s.sol:TokenAndPoolDeployer \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	--account frodo \
	--sender $(FRODO_PUBLIC_KEY) \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETHERSCAN_API_KEY) \
	-vvvv

deploy-base-sepolia:
	@forge script script/Deployer.s.sol:TokenAndPoolDeployer \
	--rpc-url $(BASE_SEPOLIA_RPC_URL) \
	--account frodo \
	--sender $(FRODO_PUBLIC_KEY) \
	--broadcast \
	--verify \
	--etherscan-api-key $(BASESCAN_API_KEY) \
	-vvvv

configure-eth-sepolia:
	@forge script script/PoolConfigurator.s.sol:PoolConfigurator \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	--account frodo \
	--sender $(FRODO_PUBLIC_KEY) \
	--broadcast \
	-vvvv

configure-base-sepolia:
	@forge script script/PoolConfigurator.s.sol:PoolConfigurator \
	--rpc-url $(BASE_SEPOLIA_RPC_URL) \
	--account frodo \
	--sender $(FRODO_PUBLIC_KEY) \
	--broadcast \
	-vvvv
