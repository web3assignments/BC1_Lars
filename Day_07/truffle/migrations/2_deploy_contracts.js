var Generator = artifacts.require("./BadgeGenerator.sol");

module.exports = function(deployer) {
  deployer.deploy(Generator)
    .then(() => Generator.deployed())
    .then((instance) => {
      instance.createBadge("test.json")
    });
};
