// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "@forge-std/Script.sol";
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {BurnMintTokenPool} from "@chainlink_/ccip/pools/BurnMintTokenPool.sol";
import {IBurnMintERC20} from "@chainlink_/shared/token/ERC20/IBurnMintERC20.sol";
import {RegistryModuleOwnerCustom} from "@chainlink_/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@chainlink_/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";

import {SnailToken} from "src/SnailToken.sol";

contract TokenAndPoolDeployer is Script {
    function run() external {
        deployTokenAndPool(msg.sender);
    }

    function deployTokenAndPool(address owner) public returns (SnailToken token, BurnMintTokenPool pool) {
        CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        Register.NetworkDetails memory networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);

        vm.startBroadcast(owner);
        token = new SnailToken();
        pool = new BurnMintTokenPool(
            IBurnMintERC20(address(token)),
            18,
            new address[](0),
            networkDetails.rmnProxyAddress,
            networkDetails.routerAddress
        );
        token.grantRole(keccak256("MINTER_ROLE"), address(pool));
        token.grantRole(keccak256("BURNER_ROLE"), address(pool));
        RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(token));
        TokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(address(token), address(pool));
        vm.stopBroadcast();
    }
}

contract TokenDeployer is Script {
    function run() external {
        deployToken(msg.sender);
    }

    function deployToken(address owner) public returns (SnailToken token) {
        vm.startBroadcast(owner);
        token = new SnailToken();
        vm.stopBroadcast();
    }
}
