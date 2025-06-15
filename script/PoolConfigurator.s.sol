// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "@forge-std/Script.sol";
import {Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {TokenPool} from "@chainlink_/ccip/pools/TokenPool.sol";
import {RateLimiter} from "@chainlink_/ccip/libraries/RateLimiter.sol";
import {BurnMintTokenPool} from "@chainlink_/ccip/pools/BurnMintTokenPool.sol";

import {TokenAndPoolHelper} from "script/Helper.s.sol";
import {SnailToken} from "src/SnailToken.sol";

contract PoolConfigurator is Script {
    function run() external {
        TokenAndPoolHelper helper = new TokenAndPoolHelper();
        TokenAndPoolHelper.Config memory config = helper.getConfig();

        configurePool(
            msg.sender,
            config.localPool,
            config.remoteChainSelector,
            config.remotePool,
            config.remoteToken,
            config.outboundRateLimiterIsEnabled,
            config.outboundRateLimiterCapacity,
            config.outboundRateLimiterRate,
            config.inboundRateLimiterIsEnabled,
            config.inboundRateLimiterCapacity,
            config.inboundRateLimiterRate
        );
    }

    function configurePool(
        address owner,
        address localPool,
        uint64 remoteChainSelector,
        address remotePool,
        address remoteToken,
        bool outboundRateLimiterIsEnabled,
        uint128 outboundRateLimiterCapacity,
        uint128 outboundRateLimiterRate,
        bool inboundRateLimiterIsEnabled,
        uint128 inboundRateLimiterCapacity,
        uint128 inboundRateLimiterRate
    ) public {
        vm.startBroadcast(owner);
        TokenPool.ChainUpdate[] memory chainsToAdd = new TokenPool.ChainUpdate[](1);
        bytes[] memory remotePoolAddresses = new bytes[](1);
        remotePoolAddresses[0] = abi.encode(address(remotePool));

        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            remotePoolAddresses: remotePoolAddresses,
            remoteTokenAddress: abi.encode(remoteToken),
            outboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: outboundRateLimiterIsEnabled,
                capacity: outboundRateLimiterCapacity,
                rate: outboundRateLimiterRate
            }),
            inboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: inboundRateLimiterIsEnabled,
                capacity: inboundRateLimiterCapacity,
                rate: inboundRateLimiterRate
            })
        });

        uint64[] memory remoteChainSelectorsToRemove = new uint64[](0);
        TokenPool(localPool).applyChainUpdates(remoteChainSelectorsToRemove, chainsToAdd);
        vm.stopBroadcast();
    }
}
