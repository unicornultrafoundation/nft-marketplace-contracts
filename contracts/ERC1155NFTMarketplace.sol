// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

import "./libraries/LibStructsMarketplace.sol";

import "./interfaces/IWETH.sol";
import "./interfaces/IFeeDistributor.sol";
import "./interfaces/INFTU2U.sol";

contract ERC1155NFTMarketplace is
  ReentrancyGuardUpgradeable,
  ERC1155HolderUpgradeable,
  OwnableUpgradeable
{
  using SafeMathUpgradeable for uint256;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  using CountersUpgradeable for CountersUpgradeable.Counter;

  struct Ask {
    address seller;
    address nft;
    uint256 tokenId;
    uint256 quantity;
    address quoteToken;
    uint256 pricePerUnit;
  }

  struct Offer {
    address buyer;
    address nft;
    uint256 tokenId;
    uint256 quantity;
    address quoteToken;
    uint256 pricePerUnit;
    uint feePerUnit;
  }

  CountersUpgradeable.Counter private _askIds;
  CountersUpgradeable.Counter private _offerIds;

  mapping(uint256 => Ask) public asks;
  mapping(uint256 => Offer) public offers;

  event AskNew(
    uint256 askId,
    address seller,
    address nft,
    uint256 tokenId,
    uint256 quantity,
    address quoteToken,
    uint256 pricePerUnit
  );

  event AskCancel(uint256 askId);

  event OfferNew(
    uint256 offerId,
    address buyer,
    address nft,
    uint256 tokenId,
    uint256 quantity,
    address quoteToken,
    uint256 pricePerUnit
  );

  event OfferCancel(uint256 offerId);

  event OfferAccept(
    uint256 offerId,
    address seller,
    uint256 quantity,
    uint256 price,
    uint256 netPrice
  );

  event Buy(
    uint256 askId,
    address buyer,
    uint256 quantity,
    uint256 price,
    uint256 netPrice
  );
  event ProtocolFee(uint256 protocolFee);

  modifier notContract() {
    require(!_isContract(msg.sender), "Contract not allowed");
    require(msg.sender == tx.origin, "Proxy contract not allowed");
    _;
  }

  address public WETH;
  IFeeDistributor public feeDistributor;

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
   * @param _quantity: quantity of order
   * @param _quoteToken: quote token
   * @param _pricePerUnit: price per unit (in wei)
   */
  function createAsk(
    address _nft,
    uint256 _tokenId,
    uint256 _quantity,
    address _quoteToken,
    uint256 _pricePerUnit
  ) external nonReentrant notContract {
    require(
      _quantity > 0,
      "ERC1155NFTMarket: _quantity must be greater than zero"
    );
    require(
      _pricePerUnit > 0,
      "ERC1155NFTMarket: _pricePerUnit must be greater than zero"
    );

    _askIds.increment();
    IERC1155Upgradeable(_nft).safeTransferFrom(
      _msgSender(),
      address(this),
      _tokenId,
      _quantity,
      ""
    );
    asks[_askIds.current()] = Ask({
      seller: _msgSender(),
      nft: _nft,
      tokenId: _tokenId,
      quoteToken: _quoteToken,
      pricePerUnit: _pricePerUnit,
      quantity: _quantity
    });

    emit AskNew(
      _askIds.current(),
      _msgSender(),
      _nft,
      _tokenId,
      _quantity,
      _quoteToken,
      _pricePerUnit
    );
  }

  /**
 * @notice Buy nft using ETH
 * @param askId: id of ask
 * @param quantity: quantity to buy
 */
  function buyUsingEth(uint256 askId, uint256 quantity)
    external
    payable
    nonReentrant
    notContract
  {
    Ask storage ask = asks[askId];
    require(
      quantity > 0 && ask.quantity >= quantity,
      "ERC1155NFTMarket: quantity must be greater than zero and less than seller's quantity"
    );
    require(address(feeDistributor) != address(0), "U2U: feeDistributor 0");
    require(
      ask.quoteToken == address(WETH), // Check if the quote token is WETH
      "ERC1155NFTMarket: ask is not in WETH"
    );
    
    uint256 price = ask.pricePerUnit.mul(quantity);
    (, uint feeBuyer,, uint netReceived) = feeDistributor.calculateFee(price, ask.nft, ask.tokenId);
    require(
      msg.value >= price.add(feeBuyer),
      "ERC1155NFTMarket: insufficient ETH sent"
    );

    ask.quantity = ask.quantity.sub(quantity);
    IWETH(WETH).deposit{value: msg.value}();
    IWETH(WETH).transfer(address(feeDistributor), msg.value);
    uint256 remaining = feeDistributor.distributeFees(ask.nft, address(WETH), msg.value, ask.tokenId, price);
    // Transfer net price to the seller
    IWETH(WETH).transfer(ask.seller, netReceived);

    // Transfer excess WETH to feeRecipient
    remaining = remaining.sub(netReceived);
    if (remaining > 0) {
      IWETH(WETH).transfer(feeDistributor.protocolFeeRecipient(), remaining);
    }

    IERC1155Upgradeable(ask.nft).safeTransferFrom(
      address(this),
      msg.sender,
      ask.tokenId,
      quantity,
      ""
    );

    if (ask.quantity == 0) {
        delete asks[askId];
    }

    uint protocolFee = price.mul(feeDistributor.protocolFeePercent()).div(10000);

    emit Buy(askId, msg.sender, quantity, price, netReceived);
    emit ProtocolFee(protocolFee);
  }


  /**
  * @notice Create offer using ETH
  * @param _nft: address of NFT contract
  * @param _tokenId: token id of NFT
  * @param _quantity: quantity to offer
  */
  function createOfferUsingEth(
    address _nft,
    uint256 _tokenId,
    uint256 _quantity,
    uint _pricePerUnit
  )
    external
    payable
    nonReentrant
    notContract
  {
    require(
      _quantity > 0 && _pricePerUnit > 0,
      "ERC1155NFTMarket: _quantity and _price must be greater than zero"
    );

    uint256 totalPrice = _pricePerUnit.mul(_quantity);
    (,uint feeBuyer,,) = feeDistributor.calculateFee(totalPrice, _nft, _tokenId);
    uint feePerUnit = feeBuyer.div(_quantity);
    require(feePerUnit > 0, "U2U: fee = 0");
    require(msg.value >= totalPrice.add(feeBuyer));

    // Convert ETH to WETH
    IWETH(WETH).deposit{value: msg.value}();

    _offerIds.increment();
    offers[_offerIds.current()] = Offer({
      buyer: msg.sender,
      nft: _nft,
      tokenId: _tokenId,
      quoteToken: address(WETH), // Use WETH as the quote token
      pricePerUnit: _pricePerUnit,
      quantity: _quantity,
      feePerUnit: feePerUnit
    });

    emit OfferNew(
      _offerIds.current(),
      msg.sender,
      _nft,
      _tokenId,
      _quantity,
      address(WETH),
      _pricePerUnit
    );
  }

  /**
   * @notice Cancel Ask
   * @param askId: id of ask
   */
  function cancelAsk(uint256 askId) external nonReentrant {
    require(
      asks[askId].seller == _msgSender(),
      "ERC1155NFTMarket: only seller"
    );
    Ask memory ask = asks[askId];
    IERC1155Upgradeable(ask.nft).safeTransferFrom(
      address(this),
      ask.seller,
      ask.tokenId,
      ask.quantity,
      ""
    );
    delete asks[askId];
    emit AskCancel(askId);
  }

  /**
   * @notice Offer
   * @param _nft: address of nft contract
   * @param _tokenId: token id of nft
   * @param _quantity: quantity to offer
   * @param _quoteToken: quote token
   * @param _pricePerUnit: price per unit
   */
  function createOffer(
    address _nft,
    uint256 _tokenId,
    uint256 _quantity,
    address _quoteToken,
    uint256 _pricePerUnit
  ) external nonReentrant notContract {
    require(
      _quantity > 0 && _pricePerUnit > 0,
      "ERC1155NFTMarket: _quantity and _pricePerUnit must be greater than zero"
    );

    uint256 totalPrice = _pricePerUnit.mul(_quantity);
    (,uint feeBuyer,,) = feeDistributor.calculateFee(totalPrice, _nft, _tokenId);
    uint feePerUnit = feeBuyer.div(_quantity);
    require(feePerUnit > 0, "U2U: fee = 0");

    _offerIds.increment();
    IERC20Upgradeable(_quoteToken).safeTransferFrom(
      _msgSender(),
      address(this),
      totalPrice.add(feeBuyer)
    );
    offers[_offerIds.current()] = Offer({
      buyer: _msgSender(),
      nft: _nft,
      tokenId: _tokenId,
      quoteToken: _quoteToken,
      pricePerUnit: _pricePerUnit,
      quantity: _quantity,
      feePerUnit: feePerUnit
    });
    emit OfferNew(
      _offerIds.current(),
      _msgSender(),
      _nft,
      _tokenId,
      _quantity,
      _quoteToken,
      _pricePerUnit
    );
  }

  /**
   * @notice Cancel Offer
   * @param offerId: id of the offer
   */
  function cancelOffer(uint256 offerId) external nonReentrant {
    require(
      offers[offerId].buyer == _msgSender(),
      "ERC1155NFTMarket: only offer owner"
    );
    Offer memory offer = offers[offerId];
    IERC20Upgradeable(offer.quoteToken).safeTransfer(
      offer.buyer,
      offer.feePerUnit.mul(offer.quantity).add(offer.pricePerUnit.mul(offer.quantity))
    );
    delete offers[offerId];
    emit OfferCancel(offerId);
  }

  /**
   * @notice Accept Offer
   * @param offerId: id of the offer
   * @param quantity: quantity to accept
   */
  function acceptOffer(uint256 offerId, uint256 quantity)
    external
    nonReentrant
    notContract
  {
    Offer storage offer = offers[offerId];
    require(
      quantity > 0 && offer.quantity >= quantity,
      "ERC1155NFTMarket: quantity must be greater than zero and less than seller's quantity"
    );
    require(address(feeDistributor) != address(0), "U2U: feeDistributor 0");
    offer.quantity = offer.quantity.sub(quantity);

    uint256 price = offer.pricePerUnit.mul(quantity);
    (, uint feeBuyer ,, uint netReceived) = feeDistributor.calculateFee(price, offer.nft, offer.tokenId);
    require(feeBuyer.div(quantity) == offer.feePerUnit, "U2U: fee changed");

    if (netReceived % 2 == 1) {
      netReceived = netReceived.sub(1);
    }

    uint value = price.add(feeBuyer);
    IERC20Upgradeable(offer.quoteToken).safeTransfer(address(feeDistributor), value);
    uint remaining = feeDistributor.distributeFees(offer.nft, offer.quoteToken, value, offer.tokenId, price);
    IERC20Upgradeable(offer.quoteToken).safeTransfer(_msgSender(), netReceived);
    remaining = remaining.sub(netReceived);
    if (remaining > 0) {
      IERC20Upgradeable(offer.quoteToken).safeTransfer(feeDistributor.protocolFeeRecipient(), remaining);
    }
    IERC1155Upgradeable(offer.nft).safeTransferFrom(
      _msgSender(),
      offer.buyer,
      offer.tokenId,
      quantity,
      ""
    );
    if (offer.quantity == 0) {
      delete offers[offerId];
    }
    uint protocolFee = price.mul(feeDistributor.protocolFeePercent()).div(10000);
    emit OfferAccept(offerId, _msgSender(), quantity, price, netReceived);
    emit ProtocolFee(protocolFee);
  }

  /**
   * @notice Buy nft
   * @param askId: id of ask
   * @param quantity: quantity to buy
   */
  function buy(uint256 askId, uint256 quantity)
    external
    nonReentrant
    notContract
  {
    Ask storage ask = asks[askId];
    require(
      quantity > 0 && ask.quantity >= quantity,
      "ERC1155NFTMarket: quantity must be greater than zero and less than seller's quantity"
    );
    require(address(feeDistributor) != address(0), "U2U: feeDistributor 0");
    uint256 price = ask.pricePerUnit.mul(quantity);
    (, uint feeBuyer,, uint netReceived) = feeDistributor.calculateFee(price, ask.nft, ask.tokenId);

    ask.quantity = ask.quantity.sub(quantity);
    if (netReceived % 2 == 1) {
      netReceived = netReceived.sub(1);
    }
    
    uint value = price.add(feeBuyer);
    IERC20Upgradeable(ask.quoteToken).safeTransferFrom(
      _msgSender(),
      address(this),
      value
    );
    IERC20Upgradeable(ask.quoteToken).safeTransfer(address(feeDistributor), value);
    uint256 remaining = feeDistributor.distributeFees(ask.nft, ask.quoteToken, value, ask.tokenId, price);
    IERC20Upgradeable(ask.quoteToken).safeTransfer(ask.seller, netReceived);
    remaining = remaining.sub(netReceived);
    if (remaining > 0) {
      IERC20Upgradeable(ask.quoteToken).safeTransfer(feeDistributor.protocolFeeRecipient(), remaining);
    }
    
    IERC1155Upgradeable(ask.nft).safeTransferFrom(
      address(this),
      _msgSender(),
      ask.tokenId,
      quantity,
      ""
    );
    
    if (ask.quantity == 0) {
      delete asks[askId];
    }

    uint protocolFee = price.mul(feeDistributor.protocolFeePercent()).div(10000);
    emit Buy(askId, _msgSender(), quantity, price, netReceived);
    emit ProtocolFee(protocolFee);
  }

  function _isContract(address _addr) internal view returns (bool) {
    uint256 size;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }
}