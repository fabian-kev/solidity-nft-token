const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Token, "Galaxy", "GAL", 8, 500000 * 10**8, 1000000 * 10**8);
};
