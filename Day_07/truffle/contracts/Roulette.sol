pragma solidity >= 0.5.0 < 0.6.0;

import "./provableApi.sol";

contract Roulette is usingProvable {

    struct Game {
        address payable player;
        uint8 number;
        uint8 betType;
        uint bet;
    }

    address private owner;

    mapping (bytes32 => Game) private games;
    mapping (address => uint256) public losses;
    mapping (address => uint256) public winnings;

    /*
    BetTypes are as follow:
    0: color red
    1: color black
    2: first eighteen
    3: last eighteen
    4: number
    */

    event GameResult(bool winner, uint256 winnings, uint8 outcome);
    event LogNewProvableQuery(string description);

    constructor() public payable {
        owner = msg.sender;
    }


    function destroy() public {
        require(msg.sender == owner, "only the owner can destroy this contract");
        selfdestruct(msg.sender);
    }

    function () external payable { }



    function play(uint8 _number, uint8 _betType) public payable {
        require(msg.value > 0.1 ether, "Bet must be at least 0.1 Ether");
        require(msg.value * 2 <= address(this).balance, "Contract can't pay out that kind of money right now");
        require(_number > 0 || _number <= 36, "number must be between 0 and 37");
        require(_betType >= 0 || _betType <= 4, "number must be between 0 and 5");

        bytes32 queryId = provable_query("WolframAlpha", "random number between 1 and 37");
        emit LogNewProvableQuery("genereated random number query");

        games[queryId] = Game(msg.sender, _number, _betType, msg.value);
    }


    function __callback(bytes32 _queryId, string memory _result) public {
        require(msg.sender == provable_cbAddress());
        Game memory game = games[_queryId];
        uint8 result = uint8(uint256(keccak256(abi.encodePacked(_result))) % 2);

        uint256 playerWinnings = 0;
        bool playerWon = false;

        if(game.betType == 0) {
            if(result % 2 == 0) {
                playerWon = true;
                playerWinnings = game.bet * 2;
                winnings[game.player] += game.bet;
            } else {
                playerWon = false;
                losses[game.player] += game.bet;
            }
        } else  if(game.betType == 1) {
            if(result % 2 != 0) {
                playerWon = true;
                playerWinnings = game.bet * 2;
                winnings[game.player] += game.bet;
            } else {
                playerWon = false;
                losses[game.player] += game.bet;
            }
        } else  if(game.betType == 2) {
            if(result < 19) {
                playerWon = true;
                playerWinnings = game.bet * 2;
                winnings[game.player] += game.bet;
            } else {
                playerWon = false;
                losses[game.player] += game.bet;
            }
        } else  if(game.betType == 3) {
            if(result > 18) {
                playerWon = true;
                playerWinnings = game.bet * 2;
                winnings[game.player] += game.bet;
            } else {
                playerWon = false;
                losses[game.player] += game.bet;
            }
        }  else  if(game.betType == 4) {
            if(result == game.number) {
                playerWon = true;
                playerWinnings = game.bet * 36;
                winnings[game.player] += game.bet;
            } else {
                playerWon = false;
                losses[game.player] += game.bet;
            }
        }

        game.player.transfer(playerWinnings);


        delete games[_queryId];
        emit GameResult(playerWon, playerWinnings, result);
    }
}
