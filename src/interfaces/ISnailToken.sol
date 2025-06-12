// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from
    "@chainlink_/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @title ISnailToken Interface
/// @notice Interface for the SnailToken contract with minting, burning, and role management capabilities
interface ISnailToken is IERC20 {
    /// @notice Mints new tokens to the specified address
    /// @param account The address receiving the newly minted tokens
    /// @param amount The amount of tokens to mint
    function mint(address account, uint256 amount) external;

    /// @notice Burns a specific amount of tokens from the caller's balance
    /// @param amount The amount of tokens to burn
    function burn(uint256 amount) external;

    /// @notice Burns a specific amount of tokens from a given account
    /// @dev Caller must have appropriate permissions to burn tokens from other accounts
    /// @param account The address from which tokens will be burned
    /// @param amount The amount of tokens to burn
    function burn(address account, uint256 amount) external;

    /// @notice Burns tokens from a specified address using allowance mechanism
    /// @param account The address from which tokens will be burned
    /// @param amount The amount of tokens to burn
    function burnFrom(address account, uint256 amount) external;

    /// @notice Returns the current CCIP Admin address
    /// @return i_CCIPAdmin The address of the CCIP Admin
    function getCCIPAdmin() external returns (address);

    /// @notice Returns the role identifier required to grant minting rights
    /// @return MINTER_ROLE The bytes32 identifier for the Minter role
    function getMinterRole() external returns (bytes32);

    /// @notice Returns the role identifier required to grant burning rights
    /// @return BURNER_ROLE The bytes32 identifier for the Burner role
    function getBurnerRole() external returns (bytes32);
}
