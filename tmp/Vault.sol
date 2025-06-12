// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// import {ISnailToken} from "src/interfaces/ISnailToken.sol";

// contract Vault {
//     ISnailToken private i_token;

//     event Deposited(address indexed user, uint256 amount);
//     event Withdrawn(address indexed user, uint256 amount);

//     error Vault__CantBeZeroValue();
//     error Vault__TransferFailed();

//     constructor(ISnailToken token) {
//         i_token = token;
//     }

//     /* --------------- External Functions --------------- */

//     function deposit() external payable {
//         if (msg.value == 0) revert Vault__CantBeZeroValue();

//         i_token.mint(msg.sender, msg.value);
//         emit Deposited(msg.sender, msg.value);
//     }

//     function withdraw(uint256 amount) external {
//         if (amount == 0) revert Vault__CantBeZeroValue();

//         i_token.burn(msg.sender, amount);
//         (bool success,) = msg.sender.call{value: amount}("");
//         if (!success) revert Vault__TransferFailed();

//         emit Withdrawn(msg.sender, amount);
//     }

//     /* --------------- External & Public View/Pure Functions --------------- */

//     function getToken() external view returns (address) {
//         return address(i_token);
//     }
// }
