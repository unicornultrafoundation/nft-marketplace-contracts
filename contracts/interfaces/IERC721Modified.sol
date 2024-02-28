// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC721Modified {
    function mintNFT(address to) external returns (uint);
    function safeTransferNFTFrom(address from, address to, uint tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
}