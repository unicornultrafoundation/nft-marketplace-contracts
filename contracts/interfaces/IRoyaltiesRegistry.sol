// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "../libraries/LibStructsMarketplace.sol";

interface IRoyaltiesRegistry {
  function getRoyaltiesType(address token) external view returns (LibStructsMarketplace.RoyaltiesType);
  function getRoyalties(address token, uint tokenId) external view returns (LibStructsMarketplace.Part[] memory);
}