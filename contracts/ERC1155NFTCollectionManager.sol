// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155NFTCollectionManager is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    address public protocolFeeRecipient;
    uint256 public protocolFeePercent = 250;
    mapping(address => uint256) loyaltyFeePercent;

    uint256 public MAX_FEE = 500; // 5%

    enum CollectionStatus {
        Open,
        Close
    }

    struct Collection {
        CollectionStatus status; // Status of collection: open or close
        uint256 creatorFee;
        address creator;
    }

    mapping(address => Collection) public collections;
    EnumerableSet.AddressSet private _collectionAddressSet;

    // Events
    event NewCollection(address indexed collection, uint256 creatorFee, address creator);
    event CloseCollection(address indexed collection);   
    event ModifyCollection(address indexed collection, uint256 creatorFee, address creator);
    

    constructor(address _recipient, uint256 _feePercent) {
        protocolFeeRecipient = _recipient;
        protocolFeePercent = _feePercent;
    }

    modifier tradeAllowed (address _collection) {
        require(collections[_collection].status == CollectionStatus.Open, "The collection status was not open");
        _;
    }

    function newCollection (
        address _collection,
        address _creator,
        uint256 _creatorFee
    ) external onlyOwner {
        require(_creatorFee <= MAX_FEE, "New collection: max_fee");
        require(_collection != address(0), "New collection: zero address");
        require(_collectionAddressSet.contains(_collection), "New collection: collection already listed");
        require(ERC1155(_collection).supportsInterface(0xd9b67a26), "New collection: Not ERC1155");
        collections[_collection] = Collection({
            status: CollectionStatus.Open,
            creator: _creator,
            creatorFee: _creatorFee
        });
        _collectionAddressSet.add(_collection);
        emit NewCollection(_collection, _creatorFee, _creator);
    }

    function closeCollection(address _collection) external onlyOwner {
        require(_collectionAddressSet.contains(_collection), "Close collection: the collection not listed");
        collections[_collection].status = CollectionStatus.Close;
        _collectionAddressSet.remove(_collection);
        emit CloseCollection(_collection);
    }

    function modifyCollection(
        address _collection,
        address _creator,
        uint256 _creatorFee
    ) external onlyOwner {
        require(collections[_collection].status == CollectionStatus.Open, "Modify collection: the status was not open");
        require(_collectionAddressSet.contains(_collection), "Modify collection: the collection not listed");
        require(_creatorFee <= MAX_FEE, "Modify collection: max_fee");
        collections[_collection] = Collection({
            status: CollectionStatus.Open,
            creator: _creator,
            creatorFee: _creatorFee
        });
        emit ModifyCollection(_collection, _creatorFee, _creator);
    }

    function setProtocolFeeRecipient(address _recipient) external onlyOwner {
        require(
            _recipient != address(0),
            "ERC1155NFTCollectionManager: zero address"
        );
        protocolFeeRecipient = _recipient;
    }

    function setProtocolFeePercent(uint256 _percent) external onlyOwner {
        require(_percent <= MAX_FEE, "max_fee");
        protocolFeePercent = _percent;
    }

    function _distributeFees(
        address _nft,
        address _quoteToken,
        uint256 _price
    ) internal virtual returns (uint256) {
        uint256 fee = 0;
        uint256 sumFees = 0;

        if (protocolFeeRecipient != address(0)) {
            fee = _price.mul(protocolFeePercent).div(10000);
            IERC20(_quoteToken).safeTransfer(protocolFeeRecipient, fee);
            sumFees = sumFees.add(fee);
        }
        Collection memory cfg = collections[_nft];
        if (cfg.creator != address(0)) {
            fee = _price.mul(cfg.creatorFee).div(10000);
            if (fee > 0) {
                IERC20(_quoteToken).safeTransfer(cfg.creator, fee);
            }
            sumFees = sumFees.add(fee);
        }
        return sumFees;
    }

    function viewCollections(uint256 cursor, uint256 size)
        external
        view
        returns (
            address[] memory collectionAddresses,
            Collection[] memory collectionDetails,
            uint256
        )
    {
        uint256 length = size;
        if (length > _collectionAddressSet.length() - cursor) {
            length = _collectionAddressSet.length() - cursor;
        }
        collectionAddresses = new address[](length);
        collectionDetails = new Collection[](length);
        for (uint256 i = 0; i < length; i++) {
            collectionAddresses[i] = _collectionAddressSet.at(cursor + i);
            collectionDetails[i] = collections[collectionAddresses[i]];
        }
        return (collectionAddresses, collectionDetails, cursor + length);
    }
}