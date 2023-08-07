// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceOracle.sol";
import "./CToken.sol";

contract SimplePriceOracle is PriceOracle {
  mapping(address => uint) prices;

  // Chainlink oracle approval mapping
  mapping(address => bool) public approvedOracles;

  event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);

  modifier onlyApprovedOracle() {
    require(approvedOracles[msg.sender], "Not approved oracle");
    _;
  }

  function getUnderlyingPrice(CToken cToken) public view returns (uint) {
    address asset = _getUnderlyingAddress(cToken);
    if (approvedOracles[msg.sender]) {
      return prices[asset];
    } else {
      return 0;
    }
  }

  function setUnderlyingPrice(CToken cToken, uint underlyingPriceMantissa) public onlyApprovedOracle {
    address asset = _getUnderlyingAddress(cToken);
    emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
    prices[asset] = underlyingPriceMantissa;
  }

  // Approve Chainlink oracle
  function approvePriceOracle(address oracle) public {
    require(oracle != address(0), "Cannot approve zero address");
    approvedOracles[oracle] = true;
  }

  function setChainlinkPriceOracle() public {
    address chainlinkOracle = 0x150A58e9E6BF69ccEb1DBA5ae97C166DC8792539;
    approvePriceOracle(chainlinkOracle);
  }

  function setDirectPrice(address asset, uint price) public {
    emit PricePosted(asset, prices[asset], price, price);
    prices[asset] = price;
  }

  // v1 price oracle interface for use as backing of proxy
  function assetPrices(address asset) external view returns (uint) {
    return prices[asset];
  }
}

