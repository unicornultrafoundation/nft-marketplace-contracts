// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

interface IERC721Fingerprint {
    function verifyFingerprint(uint256 bundleId, bytes32 fingerprint) external view returns (bool);
}