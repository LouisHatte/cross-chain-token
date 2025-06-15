// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "@forge-std/Test.sol";

import {TokenDeployer} from "script/Deployer.s.sol";
import {SnailToken} from "src/SnailToken.sol";

contract SnailTokenTest is Test {
    TokenDeployer deployer;
    SnailToken token;

    address admin = makeAddr("admin");
    address arina = makeAddr("arina");

    modifier mint(address to, uint256 amount) {
        vm.prank(admin);
        token.mint(to, amount);
        _;
    }

    function setUp() external {
        deployer = new TokenDeployer();
        token = deployer.deployToken(admin);
    }

    /* --------------- Constructor --------------- */
    function testConstructor() external view {
        assertEq(token.name(), "Snail Token");
        assertEq(token.symbol(), "SNAIL");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 0);
        assertEq(token.DEFAULT_ADMIN_ROLE(), 0x00);
    }

    /* --------------- Mint --------------- */
    function testMintMustBeCalledWithMinterRole() external {
        vm.prank(arina);
        vm.expectRevert();
        token.mint(arina, 100);
    }

    function testMintPasses() external {
        vm.prank(admin);
        token.mint(arina, 100);

        assertEq(token.balanceOf(arina), 100);
        assertEq(token.totalSupply(), 100);
    }

    /* --------------- Burn --------------- */
    function testBurnMustBeCalledWithBurnerRole() external mint(arina, 100) {
        vm.prank(arina);
        vm.expectRevert();
        token.burn(arina, 75);
    }

    function testBurn2MustBeCalledWithBurnerRole() external mint(arina, 100) {
        vm.prank(arina);
        vm.expectRevert();
        token.burn(75);
    }

    function testBurnPasses() external mint(arina, 100) {
        vm.prank(arina);
        token.approve(admin, 75);

        vm.prank(admin);
        token.burn(arina, 75);

        assertEq(token.balanceOf(arina), 25);
        assertEq(token.totalSupply(), 25);
    }

    function testBurn2Passes() external mint(admin, 100) {
        vm.prank(admin);
        token.burn(75);

        assertEq(token.balanceOf(admin), 25);
        assertEq(token.totalSupply(), 25);
    }

    /* --------------- BurnFrom --------------- */
    function testBurnFromMustBeCalledWithBurnerRole() external mint(arina, 100) {
        vm.prank(arina);
        vm.expectRevert();
        token.burnFrom(arina, 75);
    }

    function testBurnFromPasses() external mint(arina, 100) {
        vm.prank(arina);
        token.approve(admin, 75);

        vm.prank(admin);
        token.burnFrom(arina, 75);

        assertEq(token.balanceOf(arina), 25);
        assertEq(token.totalSupply(), 25);
    }

    /* --------------- Getters --------------- */
    function testGetCCIPAdmin() external view {
        assertEq(token.getCCIPAdmin(), admin);
    }

    function testGetMinterRole() external view {
        assertEq(token.getMinterRole(), keccak256("MINTER_ROLE"));
    }

    function testGetBurnerRole() external view {
        assertEq(token.getBurnerRole(), keccak256("BURNER_ROLE"));
    }
}
