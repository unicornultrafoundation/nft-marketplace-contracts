// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./libraries/LibStructsMarketplace.sol";

import "./interfaces/INFTU2U.sol";

contract RoyaltiesRegistry is OwnableUpgradeable {
  uint public constant MAX_FEE = 2000; // 20%

  /// @dev stores royalties for token contract, set in setRoyaltiesByToken() method
  mapping(address => LibStructsMarketplace.RoyaltiesSet) public royaltiesByToken;

  function initialize() public initializer {
    __Ownable_init();
  }

  /// @dev emitted when royalties set for token in
  event RoyaltiesSetForContract(address indexed token, LibStructsMarketplace.Part[] royalties);
  /// @dev sets royalties for token contract in royaltiesByToken mapping and royalties type = 1
  function setRoyaltiesByToken(address token, LibStructsMarketplace.Part[] memory royalties) external {
    _checkOwner(token);
    require(royalties.length > 0, "U2U: royalties length = 0");
    uint sumRoyalties = 0;
    delete royaltiesByToken[token];
    for (uint i = 0; i < royalties.length; ++i) {
      require(royalties[i].account != address(0), "U2U: RoyaltiesByToken recipient should be present");
      require(royalties[i].value != 0, "U2U: Royalty value for RoyaltiesByToken should be > 0");
      royaltiesByToken[token].royalties.push(royalties[i]);
      sumRoyalties += royalties[i].value;
    }
    require(sumRoyalties <= MAX_FEE, "U2U: sumRoyalties > MAX_FEE");
    royaltiesByToken[token].initialized = true;
    emit RoyaltiesSetForContract(token, royalties);
  }

  function initializeRoyaltiesByToken(address token) external {
    _checkOwner(token);
    royaltiesByToken[token].initialized = true;
  }

  function removeRoyaltiesByToken(address token) external {
    _checkOwner(token);
    delete royaltiesByToken[token];
  }

  /// @dev checks if msg.sender is owner of this contract or owner of the token contract
  function _checkOwner(address token) private view {
    if ((owner() != _msgSender()) && (OwnableUpgradeable(token).owner() != _msgSender())) {
      revert("U2U: Invalid Token Owner");
    }
  }

  /// @dev tries to get royalties rarible-v2 for token and tokenId
  function _getRoyaltiesRaribleV2(address token, uint tokenId) private view returns (LibStructsMarketplace.Part[] memory) {
    try INFTU2U(token).getRaribleV2Royalties(tokenId) returns (LibStructsMarketplace.Part[] memory result) {
      return result;
    } catch {
      return new LibStructsMarketplace.Part[](0);
    }
  }

  function getRoyalties(address token, uint tokenId) external view returns (LibStructsMarketplace.Part[] memory) {
    LibStructsMarketplace.RoyaltiesSet memory royaltiesSet = royaltiesByToken[token];
    LibStructsMarketplace.RoyaltiesType royaltiesType = getRoyaltiesType(token);
    
    if (royaltiesType == LibStructsMarketplace.RoyaltiesType.Collection) {
      return royaltiesSet.royalties;
    }

    return _getRoyaltiesRaribleV2(token, tokenId);
  }

  /// @dev returns royalties type for token contract
  function getRoyaltiesType(address token) public view returns (LibStructsMarketplace.RoyaltiesType) {
    if (royaltiesByToken[token].initialized) {
      return LibStructsMarketplace.RoyaltiesType.Collection;
    }
    return LibStructsMarketplace.RoyaltiesType.NFT;
  }

  function getRoyaltiesByToken(address token) external view returns (bool, LibStructsMarketplace.Part[] memory) {
    bool initialized = royaltiesByToken[token].initialized;
    LibStructsMarketplace.Part[] memory royalties = royaltiesByToken[token].royalties;
    return (initialized, royalties);
  }
}
