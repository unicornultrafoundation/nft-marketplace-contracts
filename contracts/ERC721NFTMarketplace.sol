// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "./libraries/LibStructsMarketplace.sol";

import "./interfaces/IWETH.sol";
import "./interfaces/IFeeDistributor.sol";
import "./interfaces/INFTU2U.sol";

contract ERC721NFTMarketplace is
  ERC721HolderUpgradeable,
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable
{
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;

  IFeeDistributor public feeDistributor;

  struct Ask {
    address seller;
    address quoteToken;
    uint256 price;
  }

  struct BidEntry {
    address quoteToken;
    uint256 price;
    uint feePaid;
  }

  address public WETH;

  // nft => tokenId => ask
  mapping(address => mapping(uint256 => Ask)) public asks;
  // nft => tokenId => bidder=> bid
  mapping(address => mapping(uint256 => mapping(address => BidEntry))) public bids;

  event AskNew(
    address indexed _seller,
    address indexed _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  );
  event AskCancel(
    address indexed _seller,
    address indexed _nft,
    uint256 _tokenId
  );
  event Trade(
    address indexed _seller,
    address indexed buyer,
    address indexed _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price,
    uint256 _netPrice
  );
  event AcceptBid(
    address indexed _seller,
    address indexed bidder,
    address indexed _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price,
    uint256 _netPrice
  );
  event Bid(
    address indexed bidder,
    address indexed _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  );
  event CancelBid(
    address indexed bidder,
    address indexed _nft,
    uint256 _tokenId
  );
  event ProtocolFee(uint256 protocolFee);

  modifier notContract() {
    require(!_isContract(msg.sender), "Contract not allowed");
    require(msg.sender == tx.origin, "Proxy contract not allowed");
    _;
  }

  function initialize(address _feeDistributor, address _weth) public initializer {
    __Ownable_init();
    WETH = _weth;
    feeDistributor = IFeeDistributor(_feeDistributor);
  }

  function setFeeDistributor(address newFeeDistributor) external onlyOwner {
    require(newFeeDistributor != address(0), "U2U: zero address");
    feeDistributor = IFeeDistributor(newFeeDistributor);
  }

  /**
   * @notice Create ask order
   * @param _nft: contract address of the NFT
   * @param _tokenId: tokenId of the NFT
   * @param _quoteToken: quote token
   * @param _price: price for listing (in wei)
   */
  function createAsk(
    address _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  ) external nonReentrant notContract {
    // Verify price is not too low/high
    require(_price > 0, "Ask: Price must be greater than zero");

    IERC721Upgradeable(_nft).safeTransferFrom(_msgSender(), address(this), _tokenId);
    asks[_nft][_tokenId] = Ask({
      seller: _msgSender(),
      quoteToken: _quoteToken,
      price: _price
    });
    emit AskNew(_msgSender(), _nft, _tokenId, _quoteToken, _price);
  }

  /**
   * @notice Cancel Ask
   * @param _nft: contract address of the NFT
   * @param _tokenId: tokenId of the NFT
   */
  function cancelAsk(address _nft, uint256 _tokenId) external nonReentrant {
    // Verify the sender has listed it
    require(
      asks[_nft][_tokenId].seller == _msgSender(),
      "Ask: only seller"
    );
    IERC721Upgradeable(_nft).safeTransferFrom(address(this), _msgSender(), _tokenId);
    delete asks[_nft][_tokenId];
    emit AskCancel(_msgSender(), _nft, _tokenId);
  }

  /**
   * @notice Buy
   * @param _nft: contract address of the NFT
   * @param _tokenId: tokenId of the NFT
   * @param _quoteToken: quote token
   * @param _price: price for listing (in wei)
   */
  function buy(
    address _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  ) external notContract nonReentrant {
    require(asks[_nft][_tokenId].seller != address(0), "token is not sell");
    IERC20Upgradeable(_quoteToken).safeTransferFrom(
      _msgSender(),
      address(this),
      _price
    );
    _buy(_nft, _tokenId, _quoteToken, _price);
  }

  function _buy(
    address _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  ) private {
    require(address(feeDistributor) != address(0), "U2U: feeDistributor 0");
    Ask memory ask = asks[_nft][_tokenId];

    (, uint feeBuyer,, uint netReceived) = feeDistributor.calculateFee(ask.price, _nft, _tokenId);
    require(_price >= ask.price.add(feeBuyer), "U2U: not enough");
    require(ask.quoteToken == _quoteToken, "Buy: Incorrect qoute token");

    if (netReceived % 2 == 1) {
      netReceived = netReceived.sub(1);
    }
    
    IERC20Upgradeable(_quoteToken).safeTransfer(address(feeDistributor), _price);
    uint256 remaining = feeDistributor.distributeFees(_nft, _quoteToken, _price, _tokenId, ask.price);
    IERC20Upgradeable(_quoteToken).safeTransfer(ask.seller, netReceived);
    remaining = remaining.sub(netReceived);
    if (remaining > 0) {
      IERC20Upgradeable(_quoteToken).safeTransfer(feeDistributor.protocolFeeRecipient(), remaining);
    }
    
    IERC721Upgradeable(_nft).safeTransferFrom(address(this), _msgSender(), _tokenId);
    uint protocolFee = ask.price.mul(feeDistributor.protocolFeePercent()).div(10000);
    
    delete asks[_nft][_tokenId];
    emit Trade(
      ask.seller,
      _msgSender(),
      _nft,
      _tokenId,
      _quoteToken,
      _price,
      netReceived
    );
    emit ProtocolFee(protocolFee);
  }

  /**
   * @notice Buy using eth
   * @param _nft: contract address of the NFT
   * @param _tokenId: tokenId of the NFT
   */
  function buyUsingEth(
    address _nft,
    uint256 _tokenId
  ) external payable nonReentrant notContract {
    require(asks[_nft][_tokenId].seller != address(0), "token is not sell");
    IWETH(WETH).deposit{value: msg.value}();
    _buy(_nft, _tokenId, WETH, msg.value);
  }

  /**
   * @notice Create a offer
   * @param _nft: contract address of the NFT
   * @param _tokenId: tokenId of the NFT
   * @param _bidder: address of bidder
   * @param _quoteToken: quote token
   */
  //  * @param _price: price for listing (in wei)
  function acceptBid(
    address _nft,
    uint256 _tokenId,
    address _bidder,
    address _quoteToken
  ) external nonReentrant {
    require(address(feeDistributor) != address(0), "U2U: feeDistributor 0");

    BidEntry memory bid = bids[_nft][_tokenId][_bidder];
    (, uint feeBuyer,, uint netReceived) = feeDistributor.calculateFee(bid.price, _nft, _tokenId);
    require(feeBuyer == bid.feePaid, "U2U: fee changed");
    require(bid.quoteToken == _quoteToken, "AcceptBid: invalid quoteToken");

    if (netReceived % 2 == 1) {
      netReceived = netReceived.sub(1);
    }

    address seller = asks[_nft][_tokenId].seller;
    if (seller == _msgSender()) {
      IERC721Upgradeable(_nft).safeTransferFrom(address(this), _bidder, _tokenId);
    } else {
      seller = _msgSender();
      IERC721Upgradeable(_nft).safeTransferFrom(seller, _bidder, _tokenId);
    }

    uint value = bid.price.add(bid.feePaid);
    IERC20Upgradeable(_quoteToken).safeTransfer(address(feeDistributor), value);
    uint256 remaining = feeDistributor.distributeFees(_nft, _quoteToken, value, _tokenId, bid.price);
    IERC20Upgradeable(_quoteToken).safeTransfer(seller, netReceived);
    remaining = remaining.sub(netReceived);
    if (remaining > 0) {
      IERC20Upgradeable(_quoteToken).safeTransfer(feeDistributor.protocolFeeRecipient(), remaining);
    }

    uint protocolFee = bid.price.mul(feeDistributor.protocolFeePercent()).div(10000);

    delete asks[_nft][_tokenId];
    delete bids[_nft][_tokenId][_bidder];
    emit AcceptBid(
      seller,
      _bidder,
      _nft,
      _tokenId,
      _quoteToken,
      bid.price,
      netReceived
    );
    emit ProtocolFee(protocolFee);
  }

  function createBid(
    address _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price
  ) external notContract nonReentrant {
    (,uint feeBuyer,,) = feeDistributor.calculateFee(_price, _nft, _tokenId);
    IERC20Upgradeable(_quoteToken).safeTransferFrom(
      _msgSender(),
      address(this),
      _price.add(feeBuyer)
    );
    _createBid(_nft, _tokenId, _quoteToken, _price, feeBuyer);
  }

  function _createBid(
    address _nft,
    uint256 _tokenId,
    address _quoteToken,
    uint256 _price,
    uint feeBuyer
  ) private {
    require(_price > 0, "Bid: Price must be granter than zero");
    if (bids[_nft][_tokenId][_msgSender()].price > 0) {
      // cancel old bid
      _cancelBid(_nft, _tokenId);
    }
    bids[_nft][_tokenId][_msgSender()] = BidEntry({
      price: _price,
      quoteToken: _quoteToken,
      feePaid: feeBuyer
    });
    emit Bid(_msgSender(), _nft, _tokenId, _quoteToken, _price);
  }

  function createBidUsingEth(
    address _nft,
    uint256 _tokenId,
    uint _price
  ) external payable notContract nonReentrant {
    (,uint feeBuyer,,) = feeDistributor.calculateFee(_price, _nft, _tokenId);
    require(msg.value >= _price.add(feeBuyer), "U2U: not enough");
    IWETH(WETH).deposit{value: msg.value}();
    _createBid(_nft, _tokenId, WETH, _price, feeBuyer);
  }

  function cancelBid(address _nft, uint256 _tokenId) external nonReentrant {
    _cancelBid(_nft, _tokenId);
  }

  function _cancelBid(address _nft, uint256 _tokenId) private {
    BidEntry memory bid = bids[_nft][_tokenId][_msgSender()];
    require(bid.price > 0, "Bid: bid not found");
    IERC20Upgradeable(bid.quoteToken).safeTransfer(_msgSender(), bid.price.add(bid.feePaid));
    delete bids[_nft][_tokenId][_msgSender()];
    emit CancelBid(_msgSender(), _nft, _tokenId);
  }

  function _isContract(address _addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }
}