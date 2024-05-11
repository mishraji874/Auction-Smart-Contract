//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract Auction {

    struct ItemToAuction {
        address auctionCreator;
        string itemName;
        uint256 itemId;
        address highestBidder;
        uint256 highestBid;
        uint256 numberOfBidders;
        uint256 auctionEndTime;
        address winner;
        bool ended;
    }

    ItemToAuction[] public items;

    uint256 public itemCounter = 1;

    mapping(uint256 itemId => address[] bidders) public itemToBidders;
    mapping(uint256 itemId => mapping(address bidder => uint256 bidAmount)) public itemToBidderAmount;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    function startAuction(string memory _itemName, uint256 _auctionDuration, uint256 _startPrice) public {
        require(_startPrice != 0, "Initial price must be greater than zero!");

        _auctionDuration *= 3600;
        uint256 _auctionEndTime = block.timestamp + _auctionDuration;

        items.push(ItemToAuction({
            auctionCreator: msg.sender,
            itemName: _itemName,
            itemId: itemCounter,
            highestBidder: address(0),
            highestBid: _startPrice,
            numberOfBidders: 0,
            auctionEndTime: _auctionEndTime,
            winner: address(0),
            ended: false
        }));
        itemCounter++;
    }

    modifier validItemId(uint256 _itemId) {
        require(_itemId > 0 && _itemId <= items.length, "Invalid item ID");
        _;
    }

    modifier ended(uint256 _itemId) {
        require(block.timestamp < items[_itemId - 1].auctionEndTime, "Auction has ended.");
        _;
    }

    modifier onlyCreator(uint256 _itemId) {
        require(msg.sender == items[_itemId - 1].auctionCreator, "Only the auction creator will end the auction.");
        _;
    }

    function addresshasBid(address[] memory addresses, address addy) public pure returns (bool) {
        for(uint256 i = 0; i < addresses.length; i++) {
            if(addresses[i] == addy) {
                return true;
            }
        }
        return false;
    }

    function bid(uint256 _itemId) public validItemId(_itemId) ended(_itemId) payable {
        ItemToAuction storage item = items[_itemId - 1];
        require(msg.sender != item.auctionCreator, "Auction creator cannot bid");

        if(block.timestamp >= item.auctionEndTime) {
            endAuction(item.itemId);
        } else {
            uint256 totalBid = msg.value + itemToBidderAmount[_itemId][msg.sender];

            require(totalBid > item.highestBid, "Total bid must be greater than current highest bid.");

            itemToBidderAmount[_itemId][msg.sender] = totalBid;
            item.highestBidder = msg.sender;
            item.highestBid = totalBid;

            if(!addresshasBid(itemToBidders[_itemId], msg.sender)) {
                itemToBidders[_itemId].push(msg.sender);
                item.numberOfBidders++;
            }
        }
    }

    function endAuction(uint256 _itemId) public validItemId(_itemId) onlyCreator(_itemId) {
        ItemToAuction storage item = items[_itemId - 1];

        require(block.timestamp >= item.auctionEndTime, "Auction time has not finished yet!");
        require(!item.ended, "Auction has already been ended");

        item.ended = true;
        item.winner = item.highestBidder;

        // Transfer highest bid to the auction creator
        payable(item.auctionCreator).transfer(item.highestBid);

        //Refund bid amounts to non-winning bidders
        for(uint256 i = 0; i < itemToBidders[_itemId].length; i++) {
            address bidder = itemToBidders[_itemId][i];
            if(bidder != item.winner) {
                uint256 refundAmount = itemToBidderAmount[_itemId][bidder];
                payable(bidder).transfer(refundAmount);
            }
        }
        item.highestBidder = address(0);
    }

    function getAuctionDetails(uint256 _itemId) validItemId(_itemId) public view returns (address, string memory, uint256, uint256, address, uint256, uint256, address, bool) {
        ItemToAuction storage item = items[_itemId - 1];
        return(
            item.auctionCreator,
            item.itemName,
            item.itemId,
            item.numberOfBidders,
            item.highestBidder,
            item.highestBid,
            item.auctionEndTime,
            item.winner,
            item.ended
        );
    }

    function getItems() public view returns (ItemToAuction[] memory) {
        return items;
    }
}