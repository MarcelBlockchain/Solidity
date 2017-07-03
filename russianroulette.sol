pragma solidity ^0.4.11

contract RussianRoulette {
  enum GameState {noWager, wagerMade, wagerAccepted}
  GameState public currentState;
  uint public wager;
  address public player1;
  address public player2;
  uint public seedBlockNumber;

  modifier stateOnly(GameState expectedState) { if (expectedState==currentState) {
    _;
    } else { throw; }
  }

  function RussianRoulette {
    currentState = GameState.noWager;
  }

  function makeWager() stateOnly(GameState.noWager) payable returns (bool) {
    wager = msg.value; //value/Eth sent to the contract
    player1 = msg.sender; //creator of the contract
    currentState = GameState.wagerMade;
    return true;
  }

  function acceptWager() stateOnly(GameState.wagerMade) payable returns (bool) {
    if(msg.value == wager) {
      player2 = msg.sender;
      seedBlockNumber = block.number;
      currentState = GameState.wagerAccepted;
      return true;
    } else {
      throw;
    }
  }

  function resolveBet() stateOnly(GameState.wagerAccepted) returns (bool) {
    uint256 blockValue = uint256(block.blockhash(seedBlockNumber));
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    uint256 killPlayer = uint256(uint256(blockValue) / FACTOR);

    if (killPlayer == 0) {
      player1.send(this.balance);
    } else (killPlayer == 1) {
      player2.send(this.balance);
    }
    currentState = GameState.noWager;
    return true;
  }
}
