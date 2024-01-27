// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC1155NFTMarket {
    struct Ask {
        address seller;
        address quoteToken;
        uint256 price;
        uint256 amounts;
    }

    struct BidEntry {
        address quoteToken;
        uint256 price;
        uint256 amounts;
    }

    event AskNew(
        address indexed _seller,
        address indexed _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    );

    event AskCancel(
        address indexed _seller,
        address indexed _nft,
        uint256 _tokenId,
        uint256 _amounts
    );

    event Trade(
        address indexed _seller,
        address indexed buyer,
        address indexed _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _netPay,
        uint256 _amounts
    );

    event AcceptBid(
        address indexed _seller,
        address indexed bidder,
        address indexed _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _netPay,
        uint256 _amounts
    );
    
    event Bid(
        address indexed bidder,
        address indexed _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    );

    event CancelBid(
        address indexed bidder,
        address indexed _nft,
        uint256 _tokenId,
        uint256 _amounts
    );

    function createAsk(
        address _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    ) external;

    function cancelAsk(
        address _nft,
        uint256 _tokenId,
        uint256 _amounts
    ) external;

    function buy(
        address _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    ) external;

    function buyUsingNative(
        address _nft,
        uint256 _tokenId,
        uint256 _amounts,
        uint256 _price
    ) external payable;

    function acceptBid(
        address _nft,
        uint256 _tokenId,
        address _bidder,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    ) external;

    function createBid(
        address _nft,
        uint256 _tokenId,
        address _quoteToken,
        uint256 _price,
        uint256 _amounts
    ) external;

    function createBidUsingNative(
        address _nft,
        uint256 _tokenId,
        uint256 _price,
        uint256 _amounts
    ) external payable;

    function cancelBid(
        address _nft,
        uint256 _tokenId,
        uint256 _amounts
    ) external;

    function viewAsksByCollectionAndTokenIds(
        address _collection, 
        uint256[] calldata _tokenIds
    ) external view returns (bool[] memory statuses, Ask[] memory askInfo);

    function viewAsksByCollection(
        address _collection,
        uint256 _cursor,
        uint256 _size
    ) external view returns (uint256[] memory tokenIds, Ask[] memory askInfo, uint256);
}
