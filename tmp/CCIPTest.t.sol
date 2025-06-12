// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import {Test} from "@forge-std/Test.sol";
// import {CCIPLocalSimulator} from "@chainlink-local/src/ccip/CCIPLocalSimulator.sol";
// import {IRouterClient} from "@chainlink-local/lib/chainlink-ccip/chains/evm/contracts/interfaces/IRouterClient.sol";
// import {LinkToken} from "@chainlink-local/src/shared/LinkToken.sol";
// import {BurnMintERC677Helper} from "@chainlink-local/src/ccip/BurnMintERC677Helper.sol";
// import {Client} from "@chainlink-local/lib/chainlink-ccip/chains/evm/contracts/libraries/Client.sol";

// contract CCIPTest is Test {
//     uint256 constant STARTING_BALANCE = 5 ether;

//     CCIPLocalSimulator ccipLocalSimulator;
//     uint64 chainSelector;
//     IRouterClient sourceRouter;
//     LinkToken linkToken;
//     BurnMintERC677Helper ccipBnMToken;

//     address arina = makeAddr("arina");
//     address pasha = makeAddr("pasha");

//     function setUp() external {
//         ccipLocalSimulator = new CCIPLocalSimulator();
//         (chainSelector, sourceRouter,,, linkToken, ccipBnMToken,) = ccipLocalSimulator.configuration();
//     }

//     function _prepareScenario()
//         private
//         returns (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend)
//     {
//         ccipBnMToken.drip(arina);
//         amountToSend = 100;
//         vm.prank(arina);
//         ccipBnMToken.approve(address(sourceRouter), amountToSend);

//         tokensToSendDetails = new Client.EVMTokenAmount[](1);
//         Client.EVMTokenAmount memory tokenToSendDetails =
//             Client.EVMTokenAmount({token: address(ccipBnMToken), amount: amountToSend});
//         tokensToSendDetails[0] = tokenToSendDetails;
//     }

//     function testTransferCrossChainWithLinkFees() external {
//         (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend) = _prepareScenario();

//         uint256 balanceOfArinaBefore = ccipBnMToken.balanceOf(arina);
//         uint256 balanceOfPashaBefore = ccipBnMToken.balanceOf(pasha);

//         vm.startPrank(arina);
//         ccipLocalSimulator.requestLinkFromFaucet(arina, 5 ether);

//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(pasha),
//             data: abi.encode(""),
//             tokenAmounts: tokensToSendDetails,
//             extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
//             feeToken: address(linkToken)
//         });

//         uint256 fees = sourceRouter.getFee(chainSelector, message);
//         linkToken.approve(address(sourceRouter), fees);

//         sourceRouter.ccipSend(chainSelector, message);
//         vm.stopPrank();

//         uint256 balanceOfArinaAfter = ccipBnMToken.balanceOf(arina);
//         uint256 balanceOfPashaAfter = ccipBnMToken.balanceOf(pasha);

//         assertEq(balanceOfArinaAfter, balanceOfArinaBefore - amountToSend);
//         assertEq(balanceOfPashaAfter, balanceOfPashaBefore + amountToSend);
//     }

//     function testTransferCrossChainWithNativeGasFee() external {
//         (Client.EVMTokenAmount[] memory tokensToSendDetails, uint256 amountToSend) = _prepareScenario();

//         uint256 balanceOfArinaBefore = ccipBnMToken.balanceOf(arina);
//         uint256 balanceOfPashaBefore = ccipBnMToken.balanceOf(pasha);

//         vm.startPrank(arina);
//         deal(arina, 5 ether);

//         Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
//             receiver: abi.encode(pasha),
//             data: abi.encode(""),
//             tokenAmounts: tokensToSendDetails,
//             extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
//             feeToken: address(0)
//         });

//         uint256 fees = sourceRouter.getFee(chainSelector, message);

//         sourceRouter.ccipSend{value: fees}(chainSelector, message);
//         vm.stopPrank();

//         uint256 balanceOfArinaAfter = ccipBnMToken.balanceOf(arina);
//         uint256 balanceOfPashaAfter = ccipBnMToken.balanceOf(pasha);

//         assertEq(balanceOfArinaAfter, balanceOfArinaBefore - amountToSend);
//         assertEq(balanceOfPashaAfter, balanceOfPashaBefore + amountToSend);
//     }
// }
