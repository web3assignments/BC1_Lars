pragma solidity ^0.6.0;

import "./Mortal.sol";
import "./provableApi.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";
import "./Privilege.sol";

/// @title Play Rock Paper Scissor and earn some money
/// @author Lars Meulenbroek
/// @notice You can use this contract to play Rock Paper Scissor
/// @dev This contract allows users to play rock paper scissor against the computer using provable for the random values. Mortal for updating and Privilege to give correct access for specific users
contract RockPaperScissors is usingProvable, Mortal, Privilege {
    /// @dev using SafeMath from @openzeppelin
    using SafeMath for uint256;
    /// @dev using SignedSafeMath from @openzeppelin
    using SignedSafeMath for int256;

    /// @author lars Meulenbroek
    /// @notice A struct of a game
    struct Game {
        address payable player;
        uint8 choice;
        uint256 bet;
    }

    mapping(bytes32 => Game) private pendingGames;

    mapping(address => int256) private playerEarnings;

    uint256 public result;
    uint256 public testearnings;

    constructor() public payable {}

receive() external payable {}

fallback() external payable {}

/// @author lars Meulenbroek
/// @notice The result of a played game
/// @dev Emitted after a PlayedGame is processed
event GameResult(bool winner, uint256 earnings, uint256 result);
/// @author lars Meulenbroek
/// @notice Fired when a new provable query
/// @dev Emitted when a new query is send to the provable api
event LogNewProvableQuery(string description);

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
/// @notice Play function to start a rock paper scissors game
/// @dev sends a provable query
/// @param _choice a uint either 1 or 2 or 3
function play(uint8 _choice) public payable minimumBet(10000000000000000 wei) minimumPrivilege(Privileges.USER) allowedChoices(_choice) {
require(msg.value * 2 <= address(this).balance, "Contract is not able to pay out this bet when the user wins");

string memory query = "https://www.random.org/integers/?num=1&min=1&max=3&col=1&base=10&format=plain&rnd=new";
bytes32 queryId = provable_query("URL", query);

emit LogNewProvableQuery("generated random number between 1 - 3 query");

pendingGames[queryId] = Game(msg.sender, _choice, msg.value);
}

/// @author Lars Meulenbroek
/// @notice function to return all player earnings
function getMyEarnings() public view returns (int256 earnings) {
return playerEarnings[msg.sender];
}

/// @author Lars Meulenbroek
/// @notice function to delete all played games of specific player
function resetPlayerStats(address _address) public minimumPrivilege(Privileges.ADMIN) {
delete playerEarnings[_address];
}


/// @author Lars Meulenbroek
/// @notice function to calculate the winner of the played game
/// @param _choice and _opponentChoice are both GameChoices types
function calculateGameResult(uint _choice, uint _opponentChoice) private pure returns (bool playerWon) {
if (_choice == 1) {
if (_opponentChoice == 3) {
return true;
} else {
return false;
}
} else if (_choice == 2) {
if (_opponentChoice == 1) {
return true;
} else {
return false;
}
} else if (_choice == 3) {
if (_opponentChoice == 2) {
return true;
} else {
return false;
}
}
}



/// @author Lars Meulenbroek
/// @dev callback function to be executed only by the provable address when a provable query is send back
function __callback(bytes32 _queryId, string memory _result) public override {
require(msg.sender == provable_cbAddress());

result = parseInt(_result);

Game memory game = pendingGames[_queryId];

uint256 earnings = 0;

testearnings = game.bet.mul(2);

if(result == game.choice) {
game.player.transfer(game.bet);
emit GameResult(false,earnings, result);
} else {
bool playerWon = calculateGameResult(game.choice, result);
if(playerWon) {
earnings = game.bet.mul(2);
game.player.transfer(earnings);
playerEarnings[game.player] = playerEarnings[game.player].add(int256(game.bet));
emit GameResult(playerWon, earnings, result);
} else {
playerEarnings[game.player] = playerEarnings[game.player].sub(int256(game.bet));
emit GameResult(playerWon, earnings, result);
}
}
}
}
