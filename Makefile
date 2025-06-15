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

check-balance-eth-sepolia:
	@cast call $(SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA) \
	"balanceOf(address)(uint256)" $(FRODO_PUBLIC_KEY) \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	-vvvv

check-balance-base-sepolia:
	@cast call $(SNAIL_TOKEN_CONTRACT_BASE_SEPOLIA) \
	"balanceOf(address)(uint256)" $(FRODO_PUBLIC_KEY) \
	--rpc-url $(BASE_SEPOLIA_RPC_URL) \
	-vvvv

check-pool-version-eth-sepolia:
	@cast call $(SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA) \
	"typeAndVersion()(string)" \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	-vvvv

check-pool-version-base-sepolia:
	@cast call $(SNAIL_TOKEN_POOL_CONTRACT_BASE_SEPOLIA) \
	"typeAndVersion()(string)" \
	--rpc-url $(BASE_SEPOLIA_RPC_URL) \
	-vvvv

check-allowance-eth-sepolia:
	@cast call $(SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA) \
	"allowance(address,address)(uint256)" \
	$(FRODO_PUBLIC_KEY) $(SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA) \
	--rpc-url $(ETH_SEPOLIA_RPC_URL)

approve-eth-sepolia:
	@cast send $(SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA) \
	"approve(address,uint256)" \
	$(SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA) 1000000000000000000 \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	--account frodo

RECEIVER_ADDRESS = $(FRODO_PUBLIC_KEY)
BASE_CHAIN_SELECTOR = 10344971235874465080
RECEIVER_BYTES = 0x
AMOUNT = 1000000000000000000
LOCAL_TOKEN_ADDRESS = $(SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA)
EXTRA_ARGS = 0x

bridge-eth-base:
	cast send $(SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA) \
	"lockOrBurn((address,uint64,bytes,uint256,address,bytes))" \
	"($(RECEIVER_ADDRESS),$(BASE_CHAIN_SELECTOR),$(RECEIVER_BYTES),$(AMOUNT),$(LOCAL_TOKEN_ADDRESS),$(EXTRA_ARGS))" \
	--rpc-url $(ETH_SEPOLIA_RPC_URL) \
	--account frodo \
	-vvvvv

# bytes receiver; // abi.encode(receiver address) for dest EVM chains.
# bytes data; // Data payload.
# EVMTokenAmount[] tokenAmounts; // Token transfers.
# address feeToken; // Address of feeToken. address(0) means you will send msg.value.
# bytes extraArgs;

# getFee
# destinationChainSelector (uint64)
# 10344971235874465080
# message (tuple)
# ["0x0000000000000000000000008fb13c0177881b4551c9a81676e3014e7c8c4f73", "0x", [["0xfdf3B1C58cd5231a796027E64b266517D702885D", "1000000000000000000"]], "0x779877A7B0D9E8603169DdbD7836e478b4624789", "0x"]

# 98818196126447 (native)

# 17206665572978728 (LINK)

0.017206665572978728