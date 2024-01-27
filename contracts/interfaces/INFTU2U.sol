// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "../libraries/LibStructsMarketplace.sol";

interface INFTU2U {
  function getRaribleV2Royalties(uint tokenId) external view returns (LibStructsMarketplace.Part[] memory);
}