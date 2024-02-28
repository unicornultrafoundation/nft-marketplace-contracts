// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

interface IFeeDistributor {
  function distributeFees(
    address nft,
    address quoteToken,
    uint value,
    uint tokenId,
    uint price
  ) external returns (uint);
  function calculateFee(uint price, address nft, uint tokenId) external view returns (uint, uint, uint, uint);
  function protocolFeeRecipient() external view returns (address);
  function protocolFeePercent() external view returns (uint);
  function calculateBuyerProtocolFee(uint price) external view returns (uint);
}