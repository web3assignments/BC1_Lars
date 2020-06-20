pragma solidity ^0.6.0;

import "./Mortal.sol";
import "./Privilige.sol";
import "./provableApi.sol";
import "./SafeMath.sol";

contract RockPaperScissors is Mortal, Privilige, usingProvable {
    using SafeMath for uint256;

    enum GameChoices {ROCK, PAPER, SCISSOR}

    struct Game {
        address payable player;
        GameChoices choice;
        uint bet;
    }

    struct PlayedGame {
        Game game;
        GameChoices result;
        uint256 earnings;
    }

    mapping (bytes32 => Game) private pendingGames;
    mapping (address => PlayedGame) private playerGames;

    mapping(address => uint256) private playerLosses;
    mapping(address => uint256) private playerEarnings;



    event GameResult(bool winner, uint256 earnings);
    event LogNewProvableQuery(string description);


    modifier minimumBet(uint256 bet) {
        require(msg.value >= bet, "Minimum bet not reached");
        _;
    }

    modifier allowedChoices(uint8 _choice) {
        require(_choice == 1 || _choice == 2 || _choice == 3, "Choice must either be 1, 2 or 3");
        _;
    }


    constructor() public payable {}

fallback() external payable {}

receive() external payable {}



function play(uint8 _choice) public payable minimumPrivilige(Priviliges.USER) minimumBet(0.1 ether) allowedChoices(_choice) {
require(
msg.value * 2 <= address(this).balance,
"Contract is not able to pay that much money right now"
);


bytes32 queryId = provable_query("WolframAlpha", "A random integer in the closed interval from 1 to 3");
emit LogNewProvableQuery("genereated random number query");

pendingGames[queryId] = Game(msg.sender, getChoice(_choice), msg.value);
}


function getChoice(uint8 _choice) private pure returns (GameChoices choice) {
if(_choice == 1) {
return GameChoices.ROCK;
} else if(_choice == 2) {
return GameChoices.PAPER;
} else if(_choice == 3) {
return GameChoices.SCISSOR;
}
}

function getMyLosses() public view minimumPrivilige(Priviliges.USER) returns (uint256 losses) {
return playerLosses[msg.sender];
}

function getMyWinings() public view minimumPrivilige(Priviliges.USER) returns (uint256 winings) {
return playerEarnings[msg.sender];
}

function deletePlayerGames(address _address) public minimumPrivilige(Priviliges.ADMIN) {
delete playerGames[_address];
}

function calculateGameResult(GameChoices _choice, GameChoices _opponentChoice) private pure returns (bool playerWon) {
if(_choice == GameChoices.ROCK) {
if(_opponentChoice == GameChoices.SCISSOR) {
return true;
} else {
return false;
}
} else if(_choice == GameChoices.PAPER) {
if(_opponentChoice == GameChoices.ROCK) {
return true;
} else {
return false;
}
} if(_choice == GameChoices.SCISSOR) {
if(_opponentChoice == GameChoices.PAPER) {
return true;
} else {
return false;
}
}

}

function __callback(bytes32 _queryId, string memory _result) public override {
require(msg.sender == provable_cbAddress());
GameChoices result = getChoice(uint8(uint256(keccak256(abi.encodePacked(_result))) % 2));
Game memory game = pendingGames[_queryId];
uint256 earnings = 0;
bool playerWon = false;

if (game.choice != result) {
playerWon = calculateGameResult(game.choice, result);
if (playerWon) {
earnings = game.bet * 2;
game.player.transfer(earnings);
playerEarnings[game.player].add(earnings);
} else {
playerLosses[game.player].add(game.bet);
}
} else {
// no winner transfer funds back to user
game.player.transfer(game.bet);
}
playerGames[game.player] =PlayedGame(game, result, earnings);

delete pendingGames[_queryId];
emit GameResult(playerWon, earnings);
}
}
