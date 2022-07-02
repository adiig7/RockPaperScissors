// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RockPaperScissors is VRFConsumerBase{
    
    // amount of LINK tokens to send with the request
    uint256 public fee;

    bytes32 public keyHash;

    address[2] public players;

    bool public gameStarted;
    uint256 entryFee;
    uint256 public gameId;

    event GameStarted(uint256 gameId, uint256 entryFee);
    event PlayerJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, address winner, bytes32 requestId);

constructor(address vrfCoordinator, address linkToken,
    bytes32 vrfKeyHash, uint256 vrfFee)
    VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
        gameStarted = false;
    }

}