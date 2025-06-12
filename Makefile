-include .env

.PHONY: install test coverage

install:
	forge install \
	smartcontractkit/chainlink@v2.24.0 \
	smartcontractkit/chainlink-local@v0.2.5 \
	foundry-rs/forge-std@v1.9.7 \
	OpenZeppelin/openzeppelin-contracts@v4.8.3

test:; @forge test

coverage:
	forge coverage --report lcov && \
	genhtml lcov.info --output-directory stats && \
	open stats/index.html
