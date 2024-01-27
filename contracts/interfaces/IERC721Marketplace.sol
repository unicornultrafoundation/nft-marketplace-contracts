// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC721NFTMarket {
    // Structure definitions
    struct Ask {
        address seller;
        address quoteToken;
        uint256 price;
    }

    struct BidEntry {
        address quoteToken;
        uint256 price;
    }

    function MarketName() external view returns (string memory);

    // Event definitions
    event AskNew(address indexed _seller, address indexed _nft, uint256 _tokenId, address _quoteToken, uint256 _price);
    event AskCancel(address indexed _seller, address indexed _nft, uint256 _tokenId);
    event Trade(address indexed _seller, address indexed buyer, address indexed _nft, uint256 _tokenId, address _quoteToken, uint256 _price, uint256 _netPrice);
    event AcceptBid(address indexed _seller, address indexed bidder, address indexed _nft, uint256 _tokenId, address _quoteToken, uint256 _price, uint256 _netPrice);
    event Bid(address indexed bidder, address indexed _nft, uint256 _tokenId, address _quoteToken, uint256 _price);
    event CancelBid(address indexed bidder, address indexed _nft, uint256 _tokenId);

    // Function signatures
    function createAsk(address _nft, uint256 _tokenId, address _quoteToken, uint256 _price) external;
    function cancelAsk(address _nft, uint256 _tokenId) external;
    function buy(address _nft, uint256 _tokenId, address _quoteToken, uint256 _price, bytes32 _fingerprint) external;
    function buyUsingNative(address _nft, uint256 _tokenId) external payable;
    function acceptBid(address _nft, uint256 _tokenId, address _bidder, address _quoteToken, uint256 _price) external;
    function createBid(address _nft, uint256 _tokenId, address _quoteToken, uint256 _price) external;
    function createBidUsingNative(address _nft, uint256 _tokenId) external payable;
    function cancelBid(address _nft, uint256 _tokenId) external;
    function viewAsksByCollectionAndTokenIds(address _collection, uint256[] calldata _tokenIds) external view returns (bool[] memory statuses, Ask[] memory askInfo);
    function viewAsksByCollection(address _collection, uint256 _cursor, uint256 _size) external view returns (uint256[] memory tokenIds, Ask[] memory askInfo, uint256);
}
