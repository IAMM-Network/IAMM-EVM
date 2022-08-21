// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./ERC4907.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RentableIAMM is ERC4907 {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor(
    string memory collectionName,
    string memory collectionSymbol
  ) ERC4907(collectionName, collectionSymbol) {}

  function mint(string memory _tokenURI) public {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, _tokenURI);
  }

  function burn(uint256 tokenId) public {
    _burn(tokenId);
  }

}