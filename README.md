# Decentralized Auction Smart Contract

This project implements a decentralized auction smart contract using Foundry. It enables users to conduct auctions for various items in a secure and transparent manner on the blockchain. Participants can bid, track auctions, and finalize transactions seamlessly.

## Features
1. **Secure Auctions:** Conduct auctions securely on the blockchain, ensuring trust and transparency.
2. **Bidding:** Users can place bids on auctioned items using cryptocurrency.
3. **Item Management:** Sellers can create and manage multiple auctioned items.
4. **Automatic Auction End:** Auctions automatically end based on the specified duration.
5. **Winner Determination:** The contract automatically determines the highest bidder as the winner at the end of the auction.

## Usage
1. **Deploy Contract:** Deploy the smart contract to the desired blockchain network.
2. **Start Auction:** Use the startAuction function to initiate a new auction, specifying the item details, auction duration, and starting price.
3. **Bid:** Participants can bid on the auctioned items using the bid function, providing the bid amount along with the item ID.
4. **End Auction:** Once the auction duration ends, the seller can call the endAuction function to finalize the auction and determine the winner.


## Installation

Follow these steps to set up and deploy the decentralized token exchange smart contract:

1.  Clone the Repository:

```bash
git clone https://github.com/mishraji874/Auction-Smart-Contract.git
```

2. Navigate to the Project Directory:

```bash
cd Auction-Smart-Contract
```

### Foundry Commands:

Here are the Foundry commands for compiling, deploying, interacting with, and testing the smart contracts:

1. Initialize Foundry:

```bash
forge init
```

2. Install dependenices:

```bash
forge install
```

3. Compile smart contracts:

```bash
forge compile
```

4. Test Contracts:

```bash
forge test
```

5. Make the ```.env``` file and add your SEPOLIA_RPC_URL, PRIVATE_KEY and your ETHERSCAN_API_KEY for verification of the deployed contract.

6. Deploy Smart Contract:

    If deploying to the test network run the following command:
    ```bash
    forge script script/DeployAuction.s.sol
    ```

    If deploying to the Sepolia test network run the following command:
    ```bash
    forge script script/DeployAuction.s.sol --rpc-url ${SEPOLIA_RPC_URL} --private-key ${PRIVATE_KEY}
    ```

    And, for verification from the Etherscan about the deployed contract run the following command:
    ```bash
    forge script script/DeployAuction.s.sol --rpc-url ${SEPOLIA_RPC_URL} --private-key ${PRIVATE_KEY} --verify ${ETHERSCAN_API_KEY} --broadcast
    ```

## License:

This project is licensed under the MIT License.