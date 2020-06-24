const RockPaperScissor = artifacts.require("RockPaperScissors");

module.exports = function(deployer) {
  deployer.deploy(RockPaperScissor);
};
