// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import {Test, Vm} from "@forge-std/Test.sol";

// import {Deployer} from "script/Deployer.s.sol";
// import {SnailToken} from "src/SnailToken.sol";
// import {Vault} from "tmp/Vault.sol";
// import {RevertingReceiver} from "test/utils/RevertingReceiver.sol";

// contract SnailTokenTest is Test {
//     uint256 constant STARTING_BALANCE = 100 ether;

//     Deployer deployer;
//     SnailToken token;
//     Vault vault;
//     address revertingReceiver;

//     address arina = makeAddr("arina");
//     address owner;

//     modifier deposit(address user, uint256 amount) {
//         vm.prank(user);
//         vault.deposit{value: amount}();
//         _;
//     }

//     function setUp() external {
//         deployer = new Deployer();
//         (token, vault) = deployer.run();

//         owner = address(vault);
//         vm.deal(arina, STARTING_BALANCE);

//         revertingReceiver = address(new RevertingReceiver());
//         vm.deal(revertingReceiver, STARTING_BALANCE);
//     }

//     /* --------------- Constructor --------------- */
//     function testConstructor() external view {
//         assertEq(vault.getToken(), address(token));
//         assertEq(address(vault).balance, 0);
//     }

//     /* --------------- Deposit --------------- */
//     function testDepositCantBeZeroValue() external {
//         bytes4 error_ = Vault.Vault__CantBeZeroValue.selector;

//         vm.prank(arina);
//         vm.expectPartialRevert(error_);
//         vault.deposit{value: 0}();
//     }

//     function testDepositPasses() external {
//         vm.prank(arina);
//         vault.deposit{value: 100}();

//         assertEq(address(vault).balance, 100);
//         assertEq(token.balanceOf(arina), 100);
//     }

//     function testDepositEmitsDepositedEvent() external {
//         vm.recordLogs();
//         vm.prank(arina);
//         vault.deposit{value: 100}();

//         Vm.Log[] memory entries = vm.getRecordedLogs();
//         bytes32 topic = entries[1].topics[0];
//         address emitter = entries[1].emitter;
//         address user = address(uint160(uint256(entries[1].topics[1])));
//         uint256 amount = abi.decode(entries[1].data, (uint256));

//         assertEq(topic, keccak256("Deposited(address,uint256)"));
//         assertEq(emitter, address(vault));
//         assertEq(user, arina);
//         assertEq(amount, 100);
//     }

//     /* --------------- Withdraw --------------- */
//     function testWithdrawCantBeZeroValue() external deposit(arina, 100) {
//         bytes4 error_ = Vault.Vault__CantBeZeroValue.selector;

//         vm.prank(arina);
//         vm.expectPartialRevert(error_);
//         vault.withdraw(0);
//     }

//     function testWithdrawTransferFails() external deposit(revertingReceiver, 100) {
//         bytes4 error_ = Vault.Vault__TransferFailed.selector;

//         vm.prank(revertingReceiver);
//         vm.expectPartialRevert(error_);
//         vault.withdraw(75);
//     }

//     function testWithdrawPasses() external deposit(arina, 100) {
//         vm.prank(arina);
//         vault.withdraw(75);

//         assertEq(address(vault).balance, 25);
//         assertEq(token.balanceOf(arina), 25);
//         assertEq(arina.balance, STARTING_BALANCE - 25);
//     }

//     function testWithdrawEmitsWithdrawnEvent() external deposit(arina, 100) {
//         vm.prank(arina);
//         vm.recordLogs();
//         vault.withdraw(75);

//         Vm.Log[] memory entries = vm.getRecordedLogs();
//         bytes32 topic = entries[1].topics[0];
//         address emitter = entries[1].emitter;
//         address user = address(uint160(uint256(entries[1].topics[1])));
//         uint256 amount = abi.decode(entries[1].data, (uint256));

//         assertEq(topic, keccak256("Withdrawn(address,uint256)"));
//         assertEq(emitter, address(vault));
//         assertEq(user, arina);
//         assertEq(amount, 75);
//     }
// }
