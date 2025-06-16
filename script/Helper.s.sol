// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "@forge-std/Script.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

library Chains {
    uint256 internal constant ETH_SEPOLIA = 11155111;
    uint256 internal constant BASE_SEPOLIA = 84532;
}

contract TokenAndPoolHelper is Script {
    struct Config {
        uint64 localChainSelector;
        Register.NetworkDetails localNetworkDetails;
        address localToken;
        address localPool;
        uint64 remoteChainSelector;
        Register.NetworkDetails remoteNetworkDetails;
        address remoteToken;
        address remotePool;
        bool outboundRateLimiterIsEnabled;
        uint128 outboundRateLimiterCapacity;
        uint128 outboundRateLimiterRate;
        bool inboundRateLimiterIsEnabled;
        uint128 inboundRateLimiterCapacity;
        uint128 inboundRateLimiterRate;
    }

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    error TokenAndPoolHelper__ChainIdUnknown(uint256 chaindId);

    constructor() {
        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
    }

    function getConfig() external view returns (Config memory) {
        if (block.chainid == Chains.ETH_SEPOLIA) {
            return getEthSepoliaConfig();
        }

        if (block.chainid == Chains.BASE_SEPOLIA) {
            return getBaseSepoliaConfig();
        }

        revert TokenAndPoolHelper__ChainIdUnknown(block.chainid);
    }

    function getEthSepoliaConfig() private view returns (Config memory) {
        Register.NetworkDetails memory localNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        Register.NetworkDetails memory remoteNetworkDetails =
            ccipLocalSimulatorFork.getNetworkDetails(Chains.BASE_SEPOLIA);

        return Config({
            localChainSelector: 16015286601757825753,
            localNetworkDetails: localNetworkDetails,
            localToken: vm.envAddress("SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA"),
            localPool: vm.envAddress("SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA"),
            remoteChainSelector: 10344971235874465080,
            remoteNetworkDetails: remoteNetworkDetails,
            remoteToken: vm.envAddress("SNAIL_TOKEN_CONTRACT_BASE_SEPOLIA"),
            remotePool: vm.envAddress("SNAIL_TOKEN_POOL_CONTRACT_BASE_SEPOLIA"),
            outboundRateLimiterIsEnabled: true,
            outboundRateLimiterCapacity: 100_000,
            outboundRateLimiterRate: 167,
            inboundRateLimiterIsEnabled: true,
            inboundRateLimiterCapacity: 100_000,
            inboundRateLimiterRate: 167
        });
    }

    function getBaseSepoliaConfig() private view returns (Config memory) {
        Register.NetworkDetails memory localNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
        Register.NetworkDetails memory remoteNetworkDetails =
            ccipLocalSimulatorFork.getNetworkDetails(Chains.ETH_SEPOLIA);

        return Config({
            localChainSelector: 10344971235874465080,
            localNetworkDetails: localNetworkDetails,
            localToken: vm.envAddress("SNAIL_TOKEN_CONTRACT_BASE_SEPOLIA"),
            localPool: vm.envAddress("SNAIL_TOKEN_POOL_CONTRACT_BASE_SEPOLIA"),
            remoteChainSelector: 16015286601757825753,
            remoteNetworkDetails: remoteNetworkDetails,
            remoteToken: vm.envAddress("SNAIL_TOKEN_CONTRACT_ETH_SEPOLIA"),
            remotePool: vm.envAddress("SNAIL_TOKEN_POOL_CONTRACT_ETH_SEPOLIA"),
            outboundRateLimiterIsEnabled: true,
            outboundRateLimiterCapacity: 100_000,
            outboundRateLimiterRate: 167,
            inboundRateLimiterIsEnabled: true,
            inboundRateLimiterCapacity: 100_000,
            inboundRateLimiterRate: 167
        });
    }
}
