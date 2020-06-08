const codex = artifacts.require("Codex");

module.exports = function(deployer) {
  const _name = 'Codex';
  const _symbol = 'CDX';
  deployer.deploy(codex, _name, _symbol);
};
