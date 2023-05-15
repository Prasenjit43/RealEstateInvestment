const RealEstateInvestment = artifacts.require("RealEstateInvestment");

module.exports = function (deployer) {
  deployer.deploy(RealEstateInvestment);
};
