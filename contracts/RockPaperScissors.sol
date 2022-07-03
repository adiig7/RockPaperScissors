// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RockPaperScissors is VRFConsumerBase{
    
    uint256 public fee;
    bytes32 public keyHash;
    uint256 public gameId;
    uint256 public randomChoiceGenerated;

    event PlayerJoined(uint256 gameId, address player);
    event GameEnded(uint256 gameId, bytes32 requestId, uint256 randomChoice);

constructor(address vrfCoordinator, address linkToken,
    bytes32 vrfKeyHash, uint256 vrfFee)
    VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = vrfKeyHash;
        fee = vrfFee;
    }

    function playGame() public payable{
        emit PlayerJoined(gameId, msg.sender);
        getRandomWinner();
    }
     function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override  {
        randomChoiceGenerated = randomness % 3;
        emit GameEnded(gameId,requestId, randomChoiceGenerated);
    }

     function getRandomWinner() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        return requestRandomness(keyHash, fee);
    }
    receive() external payable {}

    fallback() external payable {}
}