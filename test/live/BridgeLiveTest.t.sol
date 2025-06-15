// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, Vm} from "@forge-std/Test.sol";

import {BurnMintTokenPool, TokenPool} from "@chainlink_/ccip/pools/BurnMintTokenPool.sol";
import {IBurnMintERC20} from "@chainlink_/shared/token/ERC20/IBurnMintERC20.sol";
import {RegistryModuleOwnerCustom} from "@chainlink_/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@chainlink_/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {RateLimiter} from "@chainlink_/ccip/libraries/RateLimiter.sol";
import {IRouterClient} from "@chainlink_/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink_/ccip/libraries/Client.sol";

import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";

import {
    ERC20,
    ERC20Burnable,
    IERC20
} from "@chainlink_/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@chainlink_/vendor/openzeppelin-solidity/v4.8.3/contracts/access/AccessControl.sol";

import {TokenAndPoolDeployer} from "script/Deployer.s.sol";
import {TokenAndPoolHelper} from "script/Helper.s.sol";
import {PoolConfigurator} from "script/PoolConfigurator.s.sol";
import {SnailToken} from "src/SnailToken.sol";

contract BridgeLiveTest is Test {
    uint256 ethSepoliaFork;
    uint256 baseSepoliaFork;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    TokenAndPoolHelper helper;
    PoolConfigurator poolConfigurator;

    SnailToken tokenEthSepolia;
    SnailToken tokenBaseSepolia;

    BurnMintTokenPool poolEthSepolia;
    BurnMintTokenPool poolBaseSepolia;

    Register.NetworkDetails networkDetailsEthSepolia;
    Register.NetworkDetails networkDetailsBaseSepolia;

    address admin = vm.envAddress("FRODO_PUBLIC_KEY");
    address arina = makeAddr("arina");

    function setUp() external {
        string memory ETHEREUM_SEPOLIA_RPC_URL = vm.envString("ETH_SEPOLIA_RPC_URL");
        string memory BASE_SEPOLIA_RPC_URL = vm.envString("BASE_SEPOLIA_RPC_URL");
        ethSepoliaFork = vm.createFork(ETHEREUM_SEPOLIA_RPC_URL);
        baseSepoliaFork = vm.createFork(BASE_SEPOLIA_RPC_URL);

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        poolConfigurator = new PoolConfigurator();
        helper = new TokenAndPoolHelper();
        vm.makePersistent(address(ccipLocalSimulatorFork));
        vm.makePersistent(address(poolConfigurator));
        vm.makePersistent(address(helper));

        // Configure pools on Ethereum Sepolia
        vm.selectFork(ethSepoliaFork);
        TokenAndPoolHelper.Config memory configEthSepolia = helper.getConfig();

        tokenEthSepolia = SnailToken(configEthSepolia.localToken);
        poolEthSepolia = BurnMintTokenPool(configEthSepolia.localPool);
        networkDetailsEthSepolia = configEthSepolia.localNetworkDetails;

        poolConfigurator.configurePool({
            owner: admin,
            localPool: configEthSepolia.localPool,
            remoteChainSelector: configEthSepolia.remoteChainSelector,
            remotePool: configEthSepolia.remotePool,
            remoteToken: configEthSepolia.remoteToken,
            outboundRateLimiterIsEnabled: configEthSepolia.outboundRateLimiterIsEnabled,
            outboundRateLimiterCapacity: configEthSepolia.outboundRateLimiterCapacity,
            outboundRateLimiterRate: configEthSepolia.outboundRateLimiterRate,
            inboundRateLimiterIsEnabled: configEthSepolia.inboundRateLimiterIsEnabled,
            inboundRateLimiterCapacity: configEthSepolia.inboundRateLimiterCapacity,
            inboundRateLimiterRate: configEthSepolia.inboundRateLimiterRate
        });

        // Configure pools on Base Sepolia
        vm.selectFork(baseSepoliaFork);
        TokenAndPoolHelper.Config memory configBaseSepolia = helper.getConfig();

        tokenBaseSepolia = SnailToken(configBaseSepolia.localToken);
        poolBaseSepolia = BurnMintTokenPool(configBaseSepolia.localPool);
        networkDetailsBaseSepolia = configBaseSepolia.localNetworkDetails;

        poolConfigurator.configurePool({
            owner: admin,
            localPool: configBaseSepolia.localPool,
            remoteChainSelector: configBaseSepolia.remoteChainSelector,
            remotePool: configBaseSepolia.remotePool,
            remoteToken: configBaseSepolia.remoteToken,
            outboundRateLimiterIsEnabled: configBaseSepolia.outboundRateLimiterIsEnabled,
            outboundRateLimiterCapacity: configBaseSepolia.outboundRateLimiterCapacity,
            outboundRateLimiterRate: configBaseSepolia.outboundRateLimiterRate,
            inboundRateLimiterIsEnabled: configBaseSepolia.inboundRateLimiterIsEnabled,
            inboundRateLimiterCapacity: configBaseSepolia.inboundRateLimiterCapacity,
            inboundRateLimiterRate: configBaseSepolia.inboundRateLimiterRate
        });
    }

    function testBridgeTokenFromEthToBaseSepolia() external {
        vm.selectFork(ethSepoliaFork);

        address linkSepolia = networkDetailsEthSepolia.linkAddress;
        ccipLocalSimulatorFork.requestLinkFromFaucet(address(arina), 20 ether);

        uint256 amountToSend = 100;
        Client.EVMTokenAmount[] memory tokenToSendDetails = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount =
            Client.EVMTokenAmount({token: address(tokenEthSepolia), amount: amountToSend});
        tokenToSendDetails[0] = tokenAmount;

        vm.prank(address(poolEthSepolia));
        tokenEthSepolia.mint(arina, amountToSend);

        vm.startPrank(arina);
        tokenEthSepolia.approve(networkDetailsEthSepolia.routerAddress, amountToSend);
        IERC20(linkSepolia).approve(networkDetailsEthSepolia.routerAddress, 20 ether);

        uint256 balanceOfArinaBeforeEthSepolia = tokenEthSepolia.balanceOf(arina);

        IRouterClient routerEthSepolia = IRouterClient(networkDetailsEthSepolia.routerAddress);
        routerEthSepolia.ccipSend(
            networkDetailsBaseSepolia.chainSelector,
            Client.EVM2AnyMessage({
                receiver: abi.encode(address(arina)),
                data: "",
                tokenAmounts: tokenToSendDetails,
                extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
                feeToken: linkSepolia
            })
        );
        vm.stopPrank();

        uint256 balanceOfArinaAfterEthSepolia = tokenEthSepolia.balanceOf(arina);
        assertEq(balanceOfArinaAfterEthSepolia, balanceOfArinaBeforeEthSepolia - amountToSend);

        ccipLocalSimulatorFork.switchChainAndRouteMessage(baseSepoliaFork);

        uint256 balanceOfArinaAfterBaseSepolia = tokenBaseSepolia.balanceOf(arina);
        assertEq(balanceOfArinaAfterBaseSepolia, amountToSend);
    }

    function testBridgeTokenFromBaseToEthSepolia() external {
        vm.selectFork(baseSepoliaFork);

        address linkSepolia = networkDetailsBaseSepolia.linkAddress;
        ccipLocalSimulatorFork.requestLinkFromFaucet(address(arina), 20 ether);

        uint256 amountToSend = 100;
        Client.EVMTokenAmount[] memory tokenToSendDetails = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount =
            Client.EVMTokenAmount({token: address(tokenBaseSepolia), amount: amountToSend});
        tokenToSendDetails[0] = tokenAmount;

        vm.prank(address(poolBaseSepolia));
        tokenBaseSepolia.mint(arina, amountToSend);

        vm.startPrank(arina);
        tokenBaseSepolia.approve(networkDetailsBaseSepolia.routerAddress, amountToSend);
        IERC20(linkSepolia).approve(networkDetailsBaseSepolia.routerAddress, 20 ether);

        uint256 balanceOfArinaBeforeBaseSepolia = tokenBaseSepolia.balanceOf(arina);

        IRouterClient routerBaseSepolia = IRouterClient(networkDetailsBaseSepolia.routerAddress);
        routerBaseSepolia.ccipSend(
            networkDetailsEthSepolia.chainSelector,
            Client.EVM2AnyMessage({
                receiver: abi.encode(address(arina)),
                data: "",
                tokenAmounts: tokenToSendDetails,
                extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
                feeToken: linkSepolia
            })
        );
        vm.stopPrank();

        uint256 balanceOfArinaAfterBaseSepolia = tokenBaseSepolia.balanceOf(arina);
        assertEq(balanceOfArinaAfterBaseSepolia, balanceOfArinaBeforeBaseSepolia - amountToSend);

        ccipLocalSimulatorFork.switchChainAndRouteMessage(ethSepoliaFork);

        uint256 balanceOfArinaAfterEthSepolia = tokenEthSepolia.balanceOf(arina);
        assertEq(balanceOfArinaAfterEthSepolia, amountToSend);
    }
}
