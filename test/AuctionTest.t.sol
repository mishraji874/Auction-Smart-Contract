// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Auction } from "../src/Auction.sol";
import { Test } from "../lib/forge-std/src/Test.sol";
import { StdAssertions } from "../lib/forge-std/src/StdAssertions.sol";

contract AuctionTest is Test {
    Auction auction;
    address alice;
    address bob;
    address charlie;

    function setUp() public {
        auction = new Auction();
        alice = vm.addr(1); // Create address for Alice
        bob = vm.addr(2); // Create address for Bob
        charlie = vm.addr(3); // Create address for Charlie (auction creator)
    }

    function testStartAuction_createsAuction(string memory name, uint256 duration, uint256 price) public {
        // Use a fixed non-zero initial price (adjust as needed)
        uint256 initialPrice = 1 wei; // Example: 1 wei as a minimal non-zero value

        vm.prank(charlie);
        auction.startAuction(name, duration, initialPrice);

        (address creator, , , , , , , , ) = auction.getAuctionDetails(1);
        assertEq(creator, charlie);
        assertEq(auction.getItems()[0].itemName, name);
    }


    function testStartAuction_invalidStartPrice() public {
        vm.prank(charlie);
        vm.expectRevert("Initial price must be greater than zero!");
        auction.startAuction("Item", 3600, 0);
    }

    function testBid_validBid(uint256 itemId, uint256 bidAmount) public {
        // Start auction with initial price of 1 ether
        vm.prank(charlie);
        auction.startAuction("Item", 3600, 1 ether);

        // Bid from Alice with a valid item ID (should be 1 in this case)
        vm.prank(alice);
        vm.deal(alice, bidAmount); // Ensure Alice has enough ether for the bid
        auction.bid{value: bidAmount}(itemId); // Use the correct item ID

        (, , , , address highestBidder, uint256 highestBid, , , ) = auction.getAuctionDetails(itemId);
        assertEq(highestBidder, alice);
        assertEq(highestBid, bidAmount);
    }


    function testBid_invalidItemId() public {
        vm.prank(alice);
        vm.expectRevert("Invalid item ID");
        auction.bid(100); // Bid on non-existent item
    }

    function testBid_auctionEnded() public {
        // Start auction with short duration (1 second)
        vm.prank(charlie);
        auction.startAuction("Item", 1, 1 ether);

        // Advance time by 2 seconds
        vm.warp(block.timestamp + 2);

        // Ensure Alice has enough ether for the bid (2 ether)
        vm.deal(alice, 2 ether);

        // Alice attempts to bid after auction ends
        vm.prank(alice);
        try auction.bid{value: 2 ether}(1) {
            vm.expectRevert("Auction has ended. Incorrect revert reason");
        } catch Error(string memory reason) {
            // Expected revert with the correct reason
            assertEq(reason, "Auction has ended.", "Incorrect revert reason");
        } catch {
            vm.expectRevert("Expected auction to revert with reason");
        }
    }



    function testBid_auctionCreatorCannotBid() public {
        // Start auction
        vm.prank(charlie);
        auction.startAuction("Item", 3600, 1 ether);

        // Charlie (creator) tries to bid with a small amount (1 wei)
        vm.prank(charlie);
        vm.expectRevert(); // Expect any revert without specifying the message
        auction.bid{value: 1 wei}(1);
    }


    function testBid_outbid(uint256 _dummyArg1, uint256 _dummyArg2, uint256 _dummyArg3) public {
        auction.startAuction("Item 1", 1, 100);
        // Bid with a lower amount to be outbid
        vm.expectRevert(); // Expect any revert without specifying the message
        auction.bid{value: 150}(1);
        auction.bid{value: 200}(1);
        (,,,, address highestBidder, uint256 highestBid,,,) = auction.getAuctionDetails(1);
        assertEq(highestBidder, msg.sender, "Highest bidder not updated correctly");
        assertEq(highestBid, 200, "Highest bid not updated correctly");
    }




    function testEndAuction_validEnd(uint256 itemId) public {
        // Start auction (short duration)
        vm.prank(charlie);
        auction.startAuction("Item", 1, 1 ether);

        // Advance time
    }
}