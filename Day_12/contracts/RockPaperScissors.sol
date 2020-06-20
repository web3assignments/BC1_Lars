pragma solidity ^0.6.0;

import "./Mortal.sol";
import "./provableApi.sol";
import "./SafeMath.sol";
import "./Privilege.sol";


/// @title Play Rock Paper Scissor and earn some money
/// @author Lars Meulenbroek
/// @notice You can use this contract to play Rock Paper Scissor
/// @dev This contract allows users to play rock paper scissor against the computer using provable for the random values. Mortal for updating and Privilege to give correct access for specific users
contract RockPaperScissors is Mortal, Privilege, usingProvable {
    /// @dev using SafeMath from @openzeppelin
    using SafeMath for uint256;

    enum GameChoices {ROCK, PAPER, SCISSOR}

    /// @author lars Meulenbroek
    /// @notice A struct of a game
    struct Game {
        address payable player;
        GameChoices choice;
        uint bet;
    }

    /// @author lars Meulenbroek
    /// @notice A struct of a played game
    struct PlayedGame {
        Game game;
        GameChoices result;
        uint256 earnings;
    }

    mapping(bytes32 => Game) private pendingGames;
    mapping(address => PlayedGame) private playerGames;

    mapping(address => uint256) private playerLosses;
    mapping(address => uint256) private playerEarnings;

    /// @author lars Meulenbroek
    /// @notice The result of a played game
    /// @dev Emitted after a PlayedGame is processed
    event GameResult(bool winner, uint256 earnings);
    /// @author lars Meulenbroek
    /// @notice Fired when a new provable query
    /// @dev Emitted when a new query is send to the provable api
    event LogNewProvableQuery(string description);


    constructor() public payable {}

receive() external payable {}

fallback() external payable {}


/// @author Lars Meulenbroek
/// @dev modifier for the minimum bet a user needs to provide to play a game
modifier minimumBet(uint256 bet) {
require(msg.value >= bet, "Minimum bet not reached");
_;
}

/// @author Lars Meulenbroek
/// @dev modifier for checking if the user has entered a valid choice
modifier allowedChoices(uint8 _choice) {
require(_choice == 1 || _choice == 2 || _choice == 3, "Choice must either be 1, 2 or 3");
_;
}

/// @author Lars Meulenbroek
/// @notice The actual flip function callable for users
/// @dev This function sends a query to provable
/// @param _choice a uint either 0 or 1
function play(uint8 _choice) public payable minimumPrivilege(Privileges.USER) minimumBet(0.1 ether) allowedChoices(_choice) {
require(
msg.value * 2 <= address(this).balance,
"Contract is not able to pay that much money right now"
);


bytes32 queryId = provable_query("WolframAlpha", "A random integer in the closed interval from 1 to 3");
emit LogNewProvableQuery("generated random number query");

pendingGames[queryId] = Game(msg.sender, getChoice(_choice), msg.value);
}


function getChoice(uint8 _choice) private pure returns (GameChoices choice) {
if (_choice == 1) {
return GameChoices.ROCK;
} else if (_choice == 2) {
return GameChoices.PAPER;
} else if (_choice == 3) {
return GameChoices.SCISSOR;
}
}

function getMyLosses() public minimumPrivilege(Privileges.USER) returns (uint256 losses) {
return playerLosses[msg.sender];
}

function getMyEarnings() public minimumPrivilege(Privileges.USER) returns (uint256 earnings) {
return playerEarnings[msg.sender];
}

function deletePlayerGames(address _address) public minimumPrivilege(Privileges.ADMIN) {
delete playerGames[_address];
}

function calculateGameResult(GameChoices _choice, GameChoices _opponentChoice) private pure returns (bool playerWon) {
if (_choice == GameChoices.ROCK) {
if (_opponentChoice == GameChoices.SCISSOR) {
return true;
} else {
return false;
}
} else if (_choice == GameChoices.PAPER) {
if (_opponentChoice == GameChoices.ROCK) {
return true;
} else {
return false;
}
}
if (_choice == GameChoices.SCISSOR) {
if (_opponentChoice == GameChoices.PAPER) {
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
playerGames[game.player] = PlayedGame(game, result, earnings);

delete pendingGames[_queryId];
emit GameResult(playerWon, earnings);
}
}
