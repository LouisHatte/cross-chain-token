// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import {Test} from "@forge-std/Test.sol";
// import {CCIPLocalSimulatorFork} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
// import {Register} from "@chainlink-local/src/ccip/Register.sol";
// import {IRouterClient} from "@chainlink-local/lib/chainlink-ccip/chains/evm/contracts/interfaces/IRouterClient.sol";
// import {LinkToken} from "@chainlink-local/src/shared/LinkToken.sol";
// import {IERC20} from "@chainlink-local/lib/forge-std/src/interfaces/IERC20.sol";
// import {BurnMintERC677Helper} from "@chainlink-local/src/ccip/BurnMintERC677Helper.sol";
// import {Client} from "@chainlink-local/lib/chainlink-ccip/chains/evm/contracts/libraries/Client.sol";

// contract CCIPForkedEnvTest is Test {
//     uint256 constant STARTING_BALANCE = 5 ether;

//     uint256 srcForkId;
//     BurnMintERC677Helper srcCCIPBnMToken;
//     IERC20 srcLinkToken;
//     IRouterClient srcRouter;

//     uint256 destForkId;
//     BurnMintERC677Helper destCCIPBnMToken;
//     uint64 destChainSelector;

//     CCIPLocalSimulatorFork ccipLocalSimulatorFork;

//     // uint64 chainSelector;
//     // IRouterClient sourceRouter;
//     // LinkToken linkToken;
//     // BurnMintERC677Helper ccipBnMToken;

//     address arina = makeAddr("arina");
//     address pasha = makeAddr("pasha");

//     function setUp() external {
//         srcForkId = vm.createSelectFork(vm.envString("ARBITRUM_SEPOLIA_RPC_URL"));
//         destForkId = vm.createFork(vm.envString("ETHEREUM_SEPOLIA_RPC_URL"));

//         ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
//         vm.makePersistent(address(ccipLocalSimulatorFork));

//         Register.NetworkDetails memory srcNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
//         srcCCIPBnMToken = BurnMintERC677Helper(srcNetworkDetails.ccipBnMAddress);
//         srcLinkToken = IERC20(srcNetworkDetails.linkAddress);
//         srcRouter = IRouterClient(srcNetworkDetails.routerAddress);

//         vm.selectFork(destForkId);
//         Register.NetworkDetails memory destNetworkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
//         destCCIPBnMToken = BurnMintERC677Helper(destNetworkDetails.ccipBnMAddress);
//         destChainSelector = destNetworkDetails.chainSelector;
//     }

//     function _prepareScenario()
//         private
//         returns (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend)
//     {
//         vm.selectFork(srcForkId);
//         srcCCIPBnMToken.drip(arina);
//         amountToSend = 100;
//         vm.prank(arina);
//         srcCCIPBnMToken.approve(address(srcRouter), amountToSend);

//         tokensToSendDetails = new Client.EVMTokenAmount[](1);
//         Client.EVMTokenAmount memory tokenToSendDetails =
//             Client.EVMTokenAmount({token: address(srcCCIPBnMToken), amount: amountToSend});
//         tokensToSendDetails[0] = tokenToSendDetails;
//     }

//     function testTransferCrossChainWithLinkFees() external {
//         (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend) = _prepareScenario();

//         vm.selectFork(srcForkId);
//         uint256 balanceOfArinaBefore = srcCCIPBnMToken.balanceOf(arina);
//         vm.selectFork(destForkId);
//         uint256 balanceOfPashaBefore = destCCIPBnMToken.balanceOf(pasha);

//         vm.selectFork(srcForkId);
//         ccipLocalSimulatorFork.requestLinkFromFaucet(arina, 10 ether);

//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(pasha),
//             data: abi.encode(""),
//             tokenAmounts: tokensToSendDetails,
//             extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
//             feeToken: address(srcLinkToken)
//         });

//         uint256 fees = srcRouter.getFee(destChainSelector, message);
//         vm.prank(arina);
//         srcLinkToken.approve(address(srcRouter), fees);

//         vm.prank(arina);
//         srcRouter.ccipSend(destChainSelector, message);

//         uint256 balanceOfArinaAfter = srcCCIPBnMToken.balanceOf(arina);
//         assertEq(balanceOfArinaAfter, balanceOfArinaBefore - amountToSend);

//         ccipLocalSimulatorFork.switchChainAndRouteMessage(destForkId);

//         vm.selectFork(destForkId);
//         uint256 balanceOfPashaAfter = destCCIPBnMToken.balanceOf(pasha);
//         assertEq(balanceOfPashaAfter, balanceOfPashaBefore + amountToSend);
//     }

//     function testTransferCrossChainWithNativeGasFee() external {
//         (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend) = _prepareScenario();

//         vm.selectFork(srcForkId);
//         uint256 balanceOfArinaBefore = srcCCIPBnMToken.balanceOf(arina);
//         vm.selectFork(destForkId);
//         uint256 balanceOfPashaBefore = destCCIPBnMToken.balanceOf(pasha);

//         vm.selectFork(srcForkId);
//         vm.deal(arina, 5 ether);

//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(pasha),
//             data: abi.encode(""),
//             tokenAmounts: tokensToSendDetails,
//             extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
//             feeToken: address(0)
//         });

//         uint256 fees = srcRouter.getFee(destChainSelector, message);

//         vm.prank(arina);
//         srcRouter.ccipSend{value: fees}(destChainSelector, message);

//         uint256 balanceOfArinaAfter = srcCCIPBnMToken.balanceOf(arina);
//         assertEq(balanceOfArinaAfter, balanceOfArinaBefore - amountToSend);

//         ccipLocalSimulatorFork.switchChainAndRouteMessage(destForkId);

//         vm.selectFork(destForkId);
//         uint256 balanceOfPashaAfter = destCCIPBnMToken.balanceOf(pasha);
//         assertEq(balanceOfPashaAfter, balanceOfPashaBefore + amountToSend);
//     }
// }
