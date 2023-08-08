// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "./CErc20.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

interface ChainLinkPriceOracle {
    function latestAnswer() external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract EquinoxPriceOracle {
  using SafeMath for uint256;
  mapping(bytes32 => address) public Oracles;

 constructor() {
    // assign the oracle for underlyingPrice to the symbol for each market
    Oracles[stringToBytes("eFTM")] = 0xf4766552D15AE4d256Ad41B6cf2933482B0680dc;
    Oracles[stringToBytes("eBTC")] = 0x8e94C22142F4A64b99022ccDd994f4e9EC86E4B4;
    Oracles[stringToBytes("eETH")] = 0x11DdD3d147E5b83D01cee7070027092397d63658;
    Oracles[stringToBytes("eUSDC")] = 0x2553f4eeb82d5A26427b8d1106C51499CBa5D99c;

  }

  function stringToBytes (string memory s) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(s));
  }

function getUnderlyingDecimals(CToken ctoken) public view returns (uint) {
    address underlying = CErc20(address(ctoken)).underlying();
    return IERC20(underlying).decimals();
}

    function getUnderlyingPrice(CToken ctoken) public view returns (uint) {
        bytes32 key = stringToBytes(ctoken.symbol());
        ChainLinkPriceOracle oracle = ChainLinkPriceOracle(Oracles[key]);
        // Scale to USD value with 18 decimals
        return oracle.latestAnswer().mul(10**(28 - getUnderlyingDecimals(ctoken)));
    }
}

