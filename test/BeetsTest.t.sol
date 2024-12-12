// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Beets} from "src/token/Beets.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract BeetsTest is Test {
    uint256 INITIAL_SUPPLY = 200_000_000 ether;
    uint256 MAX_MINTABLE_FIRST_YEAR = 20_000_000 ether;
    address TOKEN_MINTER_ADDRESS = 0xa1E849B1d6c2Fd31c63EEf7822e9E0632411ada7;
    Beets beetsToken;

    string SONIC_FORK_URL = "https://rpc.soniclabs.com";
    uint256 INITIAL_FORK_BLOCK_NUMBER = 340476;

    uint256 sonicFork;

    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        sonicFork = vm.createSelectFork(SONIC_FORK_URL, INITIAL_FORK_BLOCK_NUMBER);

        beetsToken = new Beets(INITIAL_SUPPLY);
        beetsToken.transferOwnership(TOKEN_MINTER_ADDRESS);
    }

    function testConstructor() public view {
        assertEq(beetsToken.totalSupply(), INITIAL_SUPPLY);
        assertEq(beetsToken.owner(), TOKEN_MINTER_ADDRESS);
        assertEq(beetsToken.startTimestampCurrentYear(), block.timestamp);
        assertEq(beetsToken.startingSupplyCurrentYear(), INITIAL_SUPPLY);
        assertEq(beetsToken.amountMintedCurrentYear(), 0);
        assertEq(beetsToken.getMaxAllowedSupplyCurrentYear(), 220_000_000 ether);
    }

    function testMint() public {
        uint256 amount = 1000 ether;

        vm.prank(TOKEN_MINTER_ADDRESS);
        beetsToken.mint(TOKEN_MINTER_ADDRESS, amount);

        assertEq(beetsToken.balanceOf(TOKEN_MINTER_ADDRESS), amount);
        assertEq(beetsToken.amountMintedCurrentYear(), amount);
    }

    function testMintUnAuthorized() public {
        uint256 amount = 1000 ether;

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        beetsToken.mint(TOKEN_MINTER_ADDRESS, amount);
    }

    function testMintMaxInflationRateForCurrentYearReached() public {
        uint256 amount = 20_000_001 ether;

        vm.prank(TOKEN_MINTER_ADDRESS);
        vm.expectRevert(abi.encodeWithSelector(Beets.MintAmountTooHigh.selector, MAX_MINTABLE_FIRST_YEAR));
        beetsToken.mint(TOKEN_MINTER_ADDRESS, amount);
    }
}
