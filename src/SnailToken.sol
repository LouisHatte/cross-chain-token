// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20, ERC20Burnable, IERC20} from "@openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import {AccessControl} from "@openzeppelin/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

contract SnailToken is ERC20Burnable, Ownable, AccessControl {
    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    address private immutable i_CCIPAdmin;

    constructor() ERC20("Snail Token", "SNAIL") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        i_CCIPAdmin = msg.sender;
    }

    /* --------------- External Functions --------------- */

    function mint(address account, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyRole(BURNER_ROLE) {
        super.burnFrom(account, amount);
    }

    /* --------------- Public Functions --------------- */

    function burn(uint256 amount) public override onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public override onlyRole(BURNER_ROLE) {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }

    /* --------------- External & Public View/Pure Functions --------------- */

    function getCCIPAdmin() public view returns (address) {
        return i_CCIPAdmin;
    }

    function getMinterRole() public pure returns (bytes32) {
        return MINTER_ROLE;
    }

    function getBurnerRole() public pure returns (bytes32) {
        return BURNER_ROLE;
    }
}
