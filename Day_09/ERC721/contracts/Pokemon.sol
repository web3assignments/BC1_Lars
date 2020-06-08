pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Pokemon is ERC721 {
    string[] public pokemon;
    mapping(string => bool) _pokemonExists;

    constructor (string memory name, string memory symbol, string memory baseURI) ERC721(name, symbol) public {
        _setBaseURI(baseURI);

        // mint some tokens
        mint("Pikachu");
        mint("Charizard");
        mint("Squirtle");
    }

    // E.G. pokemon = "Pikachu"
    function mint(string memory _pokemonName) public {
        require(!_pokemonExists[_pokemonName]);
        pokemon.push(_pokemonName);
        _mint(msg.sender, pokemon.length);
        _pokemonExists[_pokemonName] = true;
    }
}
