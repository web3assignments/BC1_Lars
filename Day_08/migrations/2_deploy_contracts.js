var factory = artifacts.require("./BadgeFactory.sol");

module.exports = function(deployer) {
  deployer.deploy(factory);
};
