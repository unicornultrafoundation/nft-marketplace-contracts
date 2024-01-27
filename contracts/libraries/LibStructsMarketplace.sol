// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

library LibStructsMarketplace {
  enum RoyaltiesType {
    Collection,
    NFT
  }

  struct Part {
    address payable account;
    uint96 value;
  }
  
  /// @dev struct to store royalties in royaltiesByToken
  struct RoyaltiesSet {
    bool initialized;
    Part[] royalties;
  }
}