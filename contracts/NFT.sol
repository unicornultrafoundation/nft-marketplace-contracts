// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

// For Remix IDE usage
// import "@openzeppelin/contracts@3.4/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts@3.4/token/ERC721/IERC721Metadata.sol";
// import "@openzeppelin/contracts@3.4/utils/Counters.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IERC721Modified.sol";

contract NFT is IERC721Modified, ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("NFT1", "NFTSYM1") {}

    function balanceOf(address owner) public view override(ERC721, IERC721Modified) returns (uint) {
        return super.balanceOf(owner);
    }

    function mintNFT(address to) external override returns (uint) {
        _tokenIdCounter.increment();
        _safeMint(to, _tokenIdCounter.current());

        return _tokenIdCounter.current();
    }

    function mintBatchNFT(address to, uint amount) external returns (uint[] memory) {
        uint[] memory tokenIds = new uint[](amount);
        for (uint i = 0; i < amount; i++) {
            _tokenIdCounter.increment();
            _safeMint(to, _tokenIdCounter.current());
            tokenIds[i] = _tokenIdCounter.current();
        }

        return tokenIds;
    }
    
    function safeTransferNFTFrom(address from, address to, uint tokenId) external override {
        super.safeTransferFrom(from, to, tokenId);
    }
}
