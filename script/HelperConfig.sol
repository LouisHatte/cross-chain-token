// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract HelperConfig {
    address constant ANVIL_ACCOUNT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    struct Config {
        address admin;
    }

    function getConfig() external pure returns (Config memory) {
        return Config({admin: ANVIL_ACCOUNT});
    }
}
