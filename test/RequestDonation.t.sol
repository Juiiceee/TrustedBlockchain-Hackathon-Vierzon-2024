// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/DonationProofSBT.sol";

contract DonationProofSBTTest is Test {
    DonationProofSBT public sbt;
    address public owner;
    address public user1;
    address public user2;
    address public projectAddress;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        projectAddress = address(0x3);

        sbt = new DonationProofSBT();
    }

    function testMint() public {
        uint256 amount = 1 ether;
        uint256 blockNumber = block.number;

        uint256 tokenId = sbt.mint(user1, amount, projectAddress, blockNumber);

        assertEq(sbt.ownerOf(tokenId), user1);

        (uint256 mintedAmount, address mintedProject, uint256 timestamp, uint256 mintedBlockNumber) = sbt.donationInfo(tokenId);
        assertEq(mintedAmount, amount);
        assertEq(mintedProject, projectAddress);
        assertEq(mintedBlockNumber, blockNumber);
        assertGt(timestamp, 0);
    }

    function testSetBaseURI() public {
        string memory newBaseURI = "https://example.com/";
        sbt.setBaseURI(newBaseURI);

        uint256 tokenId = sbt.mint(user1, 1 ether, projectAddress, block.number);
        assertEq(sbt.tokenURI(tokenId), string(abi.encodePacked(newBaseURI, Strings.toString(tokenId))));
    }

    function testFailMintToZeroAddress() public {
        sbt.mint(address(0), 1 ether, projectAddress, block.number);
    }

    function testFailTransfer() public {
        uint256 tokenId = sbt.mint(user1, 1 ether, projectAddress, block.number);
        vm.prank(user1);
        vm.expectRevert("SBT: transfer not allowed");
        sbt.transferFrom(user1, user2, tokenId);
    }

    function testFailSafeTransfer() public {
        uint256 tokenId = sbt.mint(user1, 1 ether, projectAddress, block.number);
        vm.prank(user1);
        vm.expectRevert("SBT: transfer not allowed");
        sbt.safeTransferFrom(user1, user2, tokenId);
    }

    function testSupportsInterface() public {
        assertTrue(sbt.supportsInterface(type(IERC721).interfaceId));
        assertTrue(sbt.supportsInterface(type(IERC721Metadata).interfaceId));
    }

    function testOnlyOwnerCanSetBaseURI() public {
        vm.prank(user1);
        vm.expectRevert("Ownable: caller is not the owner");
        sbt.setBaseURI("https://newuri.com/");
    }

    function testEmitEvent() public {
        uint256 amount = 1 ether;
        uint256 blockNumber = block.number;

        vm.expectEmit(true, true, true, true);
        emit DonationProofSBT.DonationProofMinted(user1, amount, projectAddress, 0);
        
        sbt.mint(user1, amount, projectAddress, blockNumber);
    }
}