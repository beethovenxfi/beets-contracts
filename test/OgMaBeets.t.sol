// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {OgMaBeets} from "src/og-mabeets/OgMaBeets.sol";

contract OgMaBeetsTest is Test {
    string SONIC_FORK_URL = "https://rpc.soniclabs.com";
    uint256 INITIAL_FORK_BLOCK_NUMBER = 10505083;
    uint256 sonicFork;

    OgMaBeets ogNftContract;

    error OwnableUnauthorizedAccount(address account);

    function setUp() public {
        sonicFork = vm.createSelectFork(SONIC_FORK_URL, INITIAL_FORK_BLOCK_NUMBER);

        ogNftContract = new OgMaBeets();
    }

    function testConstructor() public view {
        assertEq(ogNftContract.name(), "OG maBeets position");
        assertEq(ogNftContract.symbol(), "OGmaBEETS");
    }

    function testMint() public {
        uint256 amount = 100 ether;
        uint256 level = 10;

        address owner = vm.addr(1);

        uint256 id = ogNftContract.mint(owner, level, amount);
        OgMaBeets.OgPositionInfo memory position = ogNftContract.getPositionForId(id);

        assertEq(position.amount, amount);
        assertEq(position.level, level);
        assertEq(ogNftContract.ownerOf(id), owner);
        assertEq(ogNftContract.totalSupply(), 1);
    }

    function testMultiMint() public {
        uint256 amount1 = 100 ether;
        uint256 level1 = 10;
        uint256 amount2 = 200 ether;
        uint256 level2 = 5;
        uint256 amount3 = 120 ether;
        uint256 level3 = 3;

        address owner1 = vm.addr(1);
        address owner2 = vm.addr(2);

        uint256 id1 = ogNftContract.mint(owner1, level1, amount1);
        OgMaBeets.OgPositionInfo memory position1 = ogNftContract.getPositionForId(id1);

        assertEq(position1.amount, amount1);
        assertEq(position1.level, level1);
        assertEq(ogNftContract.ownerOf(id1), owner1);
        assertEq(ogNftContract.totalSupply(), 1);

        uint256 id2 = ogNftContract.mint(owner1, level2, amount2);
        OgMaBeets.OgPositionInfo memory position2 = ogNftContract.getPositionForId(id2);

        assertEq(position2.amount, amount2);
        assertEq(position2.level, level2);
        assertEq(ogNftContract.ownerOf(id2), owner1);
        assertEq(ogNftContract.totalSupply(), 2);

        uint256 id3 = ogNftContract.mint(owner2, level3, amount3);
        OgMaBeets.OgPositionInfo memory position3 = ogNftContract.getPositionForId(id3);

        assertEq(position3.amount, amount3);
        assertEq(position3.level, level3);
        assertEq(ogNftContract.ownerOf(id3), owner2);
        assertEq(ogNftContract.totalSupply(), 3);
    }

    function testTransfer() public {
        uint256 amount1 = 100 ether;
        uint256 level1 = 10;

        address owner1 = vm.addr(1);
        address owner2 = vm.addr(2);

        uint256 id1 = ogNftContract.mint(owner1, level1, amount1);
        OgMaBeets.OgPositionInfo memory position1 = ogNftContract.getPositionForId(id1);

        assertEq(position1.amount, amount1);
        assertEq(position1.level, level1);
        assertEq(ogNftContract.ownerOf(id1), owner1);
        assertEq(ogNftContract.totalSupply(), 1);

        vm.prank(owner1);
        ogNftContract.safeTransferFrom(owner1, owner2, id1);
        assertEq(ogNftContract.ownerOf(id1), owner2);
    }

    function testSetTokenUri() public {
        uint256 amount1 = 100 ether;
        uint256 level1 = 10;

        address owner1 = vm.addr(1);

        uint256 id1 = ogNftContract.mint(owner1, level1, amount1);
        OgMaBeets.OgPositionInfo memory position1 = ogNftContract.getPositionForId(id1);

        assertEq(position1.amount, amount1);
        assertEq(position1.level, level1);
        assertEq(ogNftContract.ownerOf(id1), owner1);
        assertEq(ogNftContract.totalSupply(), 1);
        assertEq(ogNftContract.tokenURI(1), "https://beethoven-assets.s3.eu-central-1.amazonaws.com/og-relic-nft.png");

        ogNftContract.setTokenURI("https://beethoven-assets.s3.eu-central-1.amazonaws.com/og-relic-nft2.png");
        assertEq(ogNftContract.tokenURI(1), "https://beethoven-assets.s3.eu-central-1.amazonaws.com/og-relic-nft2.png");
    }

    function testOnlyOwnerCanMint() public {
        address user = vm.addr(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(user)));
        ogNftContract.mint(user, 10, 1000 ether);
    }

    function testOnlyOwnerCanSetURI() public {
        address user = vm.addr(1);

        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(user)));
        ogNftContract.setTokenURI("https://beethoven-assets.s3.eu-central-1.amazonaws.com/og-relic-nft2.png");
    }
}
