//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Auction} from "../src/Auction.sol";

contract DeployAuction is Script {
    
    function run() external returns (Auction) {
        vm.startBroadcast();
        Auction auction = new Auction();
        vm.stopBroadcast();
        return auction;
    }
}