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
import {PoolConfigurator} from "script/PoolConfigurator.s.sol";
import {SnailToken} from "src/SnailToken.sol";

contract BridgeTest is Test {
    uint256 ethSepoliaFork;
    uint256 baseSepoliaFork;

    CCIPLocalSimulatorFork ccipLocalSimulatorFork;

    TokenAndPoolDeployer tokenAndPoolDeployer;
    PoolConfigurator poolConfigurator;

    SnailToken public tokenEthSepolia;
    SnailToken public tokenBaseSepolia;

    BurnMintTokenPool public poolEthSepolia;
    BurnMintTokenPool public poolBaseSepolia;

    Register.NetworkDetails networkDetailsEthSepolia;
    Register.NetworkDetails networkDetailsBaseSepolia;

    address arina = makeAddr("arina");

    function setUp() external {
        string memory ETHEREUM_SEPOLIA_RPC_URL = vm.envString("ETHEREUM_SEPOLIA_RPC_URL");
        string memory BASE_SEPOLIA_RPC_URL = vm.envString("BASE_SEPOLIA_RPC_URL");
        ethSepoliaFork = vm.createSelectFork(ETHEREUM_SEPOLIA_RPC_URL);
        baseSepoliaFork = vm.createFork(BASE_SEPOLIA_RPC_URL);

        ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
        tokenAndPoolDeployer = new TokenAndPoolDeployer();
        poolConfigurator = new PoolConfigurator();
        vm.makePersistent(address(ccipLocalSimulatorFork));
        vm.makePersistent(address(tokenAndPoolDeployer));
        vm.makePersistent(address(poolConfigurator));

        // Deploy token and pool on Ethereum Sepolia
        (tokenEthSepolia, poolEthSepolia, networkDetailsEthSepolia) = tokenAndPoolDeployer.run();

        // Deploy token and pool on Base Sepolia
        vm.selectFork(baseSepoliaFork);
        (tokenBaseSepolia, poolBaseSepolia, networkDetailsBaseSepolia) = tokenAndPoolDeployer.run();

        // Configure pools on Base Sepolia
        poolConfigurator.run({
            localPool: address(poolBaseSepolia),
            remoteChainSelector: networkDetailsEthSepolia.chainSelector,
            remotePool: address(poolEthSepolia),
            remoteToken: address(tokenEthSepolia),
            outboundRateLimiterIsEnabled: true,
            outboundRateLimiterCapacity: 100_000,
            outboundRateLimiterRate: 167,
            inboundRateLimiterIsEnabled: true,
            inboundRateLimiterCapacity: 100_000,
            inboundRateLimiterRate: 167
        });

        // Configure pools on Ethereum Sepolia
        vm.selectFork(ethSepoliaFork);
        poolConfigurator.run({
            localPool: address(poolEthSepolia),
            remoteChainSelector: networkDetailsBaseSepolia.chainSelector,
            remotePool: address(poolBaseSepolia),
            remoteToken: address(tokenBaseSepolia),
            outboundRateLimiterIsEnabled: true,
            outboundRateLimiterCapacity: 100_000,
            outboundRateLimiterRate: 167,
            inboundRateLimiterIsEnabled: true,
            inboundRateLimiterCapacity: 100_000,
            inboundRateLimiterRate: 167
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
