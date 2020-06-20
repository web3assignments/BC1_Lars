const RockPaperScissor = artifacts.require("RockPaperScissors");

module.exports = function(deployer) {
  deployer.deploy(RockPaperScissor, {value: web3.utils.toWei("2", "ether")});
};
