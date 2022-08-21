// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BEP20USDT.sol";
import "./ERC4907.sol";

contract RentableIAMM is ERC4907, Ownable, Pausable, AccessControl {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  using Address for address;
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  //Price    
    uint256 private priceInOperationToken;
    //TODO:Implement price by Sell Phase
    //Max Token Number Allowed to buy per purchase
    uint248 private maxMintPerBuy;
    //Token for payments: 1: Matic 2: MetaToken  3: USDC
    uint8 private operationToken;
    //Buyers list
    mapping (address => uint256) public buyers;
    //USDT contract
    address private operationTokenContract;
    //GNosis IAMM Wallet
    address private IAMMWallet;
    //User wallet
    address private creatorWallet;
    //General Supply
    uint256 public minted;
    //Is transferable
    bool private isTransferable;
    //Metadata Root
    string metadataRoot;

    mapping(address => mapping(address => bool)) private _operatorApprovals;
    
    event PriceChanged(address changer, uint256 price);
    event maxMintPerBuyChanged(address changer, uint248 price);
    event MintersUpdated(address changer, address newMinter);

  constructor(
    string memory collectionName,
    string memory collectionSymbol,
    string memory _metadataRoot,
    uint256 _priceInOperationToken, 
    uint248 _maxMintPerBuy, 
    address _operationTokenContract, 
    address _creatorWallet, 
    uint8 _operationToken,
    bool _isTransferable
  ) ERC4907(collectionName, collectionSymbol) {

      metadataRoot = _metadataRoot;
      priceInOperationToken = _priceInOperationToken;
      maxMintPerBuy = _maxMintPerBuy;
      operationTokenContract = _operationTokenContract;
      
      creatorWallet = _creatorWallet;
      operationToken = _operationToken;

      IAMMWallet = 0xC2ED628B4bFa24a4d9BdA3Cc8479dd411f28a9Ab;

      isTransferable = _isTransferable;

      _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
      _setupRole(MINTER_ROLE, msg.sender);
  }

  function updatePrice(uint256 _priceInOperationToken) public onlyOwner {
        priceInOperationToken = _priceInOperationToken;
        emit PriceChanged(msg.sender, _priceInOperationToken);
    }

    function updateMaxMint(uint248 _maxMintPerBuy) public onlyOwner {
        maxMintPerBuy = _maxMintPerBuy;
        emit maxMintPerBuyChanged(msg.sender, _maxMintPerBuy);
    }

    function setMinter(address newMinter) public onlyOwner {
        _setupRole(MINTER_ROLE, newMinter);
        emit MintersUpdated(msg.sender, newMinter);
    }

  function mint(uint256 amount) public returns(bool){

    require(priceInOperationToken == amount, "The amount needs to be equals priceInOperationToken");

    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    //validates previous amount
    uint256 previousMintedTokens = buyers[msg.sender];

    uint256 newmintNumber = 0;

    //TODO: validate mintNum by transaction, max 400 mintNum
    if(previousMintedTokens > 0) {
        //validates new TokensToMint number
        newmintNumber = previousMintedTokens + 1;
        require(newmintNumber <= maxMintPerBuy, "Can't buy more TokensToMint");
    }
    else 
        newmintNumber = 1;
    
    //Do the transfer in USDT contract
    //Requires a previous increase allowance directly in the USDT contract
    BEP20USDT USDT = BEP20USDT(operationTokenContract);

    USDT.transferFrom(msg.sender, creatorWallet, amount);

    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, metadataRoot);

    
    buyers[msg.sender] = newmintNumber;

    minted += 1;

    return true;        

  }

  function burn(uint256 tokenId) public {

    _burn(tokenId);

  }

  function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        
        require(isTransferable, "RentableIAMM: The token is not tranferable");
        require(_isApprovedOrOwner(_msgSender(), tokenId), "RentableIAMM: caller is not token owner nor approved");

        _transfer(from, to, tokenId);
    }

  function safeTransferFrom(
      address from,
      address to,
      uint256 tokenId,
      bytes memory data
  ) public virtual override {

      require(isTransferable, "RentableIAMM: The token is not tranferable");
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
      _safeTransfer(from, to, tokenId, data);
      
  }

  function supportsInterface(bytes4 interfaceId) 
        public view virtual override(ERC4907, AccessControl) returns (bool) 
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

}