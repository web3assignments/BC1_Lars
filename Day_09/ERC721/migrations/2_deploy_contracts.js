const pokemon = artifacts.require("Pokemon");

module.exports = function(deployer) {
  deployer.deploy(pokemon, "Pokemon", "PKM", "https://web3assignments.github.io/BC2_Lars/Day_09/ERC721/Tokens/");
};
