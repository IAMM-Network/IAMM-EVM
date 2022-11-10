// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./BEP20USDT.sol";


contract IAMM1155 is ERC165, IERC1155, IERC1155MetadataURI, Ownable, Pausable, AccessControl{
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
    //Using promoters for your token?
    bool private usinPromoters;
    //Minted by promotion minters list
    mapping (address => uint256) public promotions;
    //General Supply
    uint256 public minted;
    //Token Name
    string private _name;
    //Token Symbol
    string private _symbol;
    //Metadata Root
    string metadataRoot;

    mapping(uint256 => mapping(address => uint256)) private _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    
    event PriceChanged(address changer, uint8 price);
    event maxMintPerBuyChanged(address changer, uint248 price);
    event MintersUpdated(address changer, address newMinter);

    constructor(
        string memory collectionName,
        string memory collectionSymbol,
        uint8 _priceInOperationToken, 
        uint248 _maxMintPerBuy, 
        address _operationTokenContract, 
        address _creatorWallet, 
        string memory initMetadataRoot,
        uint8 _operationToken,
        bool _usinPromoters  ) {

        _name = collectionName;
        _symbol = collectionSymbol;
        priceInOperationToken = _priceInOperationToken;
        maxMintPerBuy = _maxMintPerBuy;
        operationTokenContract = _operationTokenContract;
        
        creatorWallet = _creatorWallet;
        metadataRoot = initMetadataRoot;
        operationToken = _operationToken;
        usinPromoters = _usinPromoters;

        IAMMWallet = 0xC2ED628B4bFa24a4d9BdA3Cc8479dd411f28a9Ab;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        
    }

    function updatePrice(uint8 _priceInOperationToken) public onlyOwner {
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

    function mint(uint256 mintNum, uint256 amount) public returns(bool){

        //validates the number of TokensToMint is more than 0
        require(mintNum > 0, "Needs to provide a valid number of TokensToMint");
        //validates mintNum * priceInOperationToken = amount
        require(mintNum * priceInOperationToken == amount, "The amount needs to be equals mintNum * priceInOperationToken");
        //validates previous amount
        uint256 previousMintedTokens = buyers[msg.sender];

        uint256 newmintNumber = 0;

        //TODO: validate mintNum by transaction, max 400 mintNum
        if(previousMintedTokens > 0) {
            //validates new TokensToMint number
            newmintNumber = previousMintedTokens + mintNum;
            require(newmintNumber <= maxMintPerBuy, "Can't buy more TokensToMint");
        }
        else 
            newmintNumber = mintNum;
        
        //Do the transfer in USDT contract
        //Requires a previous increase allowance directly in the USDT contract
        BEP20USDT USDT = BEP20USDT(operationTokenContract);

        USDT.transferFrom(msg.sender, creatorWallet, amount);

        _balances[0][msg.sender] = newmintNumber;
        emit TransferSingle(msg.sender, address(0), msg.sender, 0, mintNum);

        buyers[msg.sender] = newmintNumber;

        minted += mintNum;

        return true;        
    }

    function mintPromotions(uint256 mintNum) public onlyRole(MINTER_ROLE) returns(bool){

        //validates the number of TokensToMint is more than 0
        require(mintNum > 0, "Needs to provide a valid number of TokensToMint");

        //validates previous amount
        uint256 previousMintedTokens = buyers[msg.sender];

        uint256 newmintNumber = 0;

        //validate mintNum by transaction
        if(previousMintedTokens > 0) {
            //validates new TokensToMint number
            newmintNumber = previousMintedTokens + mintNum;
            require(newmintNumber <= maxMintPerBuy, "Can't buy more TokensToMint");
        }
        else 
            newmintNumber = mintNum;
        
        buyers[msg.sender] = newmintNumber;

        promotions[msg.sender] = newmintNumber;

        minted += mintNum;

        return true;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return 0;
    }

    function totalSupply() public view returns (uint256) {
        return minted;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[0][account];
    }

    function tokenURI(uint256 id) external view returns (string memory) {
        return uri(id);
    }

    function uri(uint256 id) override public view returns (string memory) {
        return string(abi.encodePacked(metadataRoot, Strings.toString(id), ".json"));
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public view virtual override returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");
        uint256[] memory batchBalances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }
        return batchBalances;
    } 

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(msg.sender != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address account, address operator) 
        public view virtual override returns (bool) 
    {
        return _operatorApprovals[account][operator];
    }  

    function supportsInterface(bytes4 interfaceId) 
        public view virtual override(ERC165, IERC165, AccessControl) returns (bool) 
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        require(to != address(0), "ERC1155: transfer to the zero address");
        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;
        emit TransferSingle(msg.sender, from, to, id, amount);
        _balances[0][from] -= amount;
        _balances[0][to] += amount;
        emit TransferSingle(msg.sender, from, to, 0, amount);
        _doSafeTransferAcceptanceCheck(msg.sender, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == msg.sender || isApprovedForAll(from, msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        uint256[] memory types = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            // require(
            //     id & NFT_INDEX_MASK != 0, 
            //     "NFT index 0 represents total NFTs holded and can't be transferred"
            // );
            uint256 amount = amounts[i];
            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
            _balances[0][from] -= amount;
            _balances[0][to] += amount;
            types[i] = id;
        }
        emit TransferBatch(msg.sender, from, to, ids, amounts);
        emit TransferBatch(msg.sender, from, to, types, amounts);
        _doSafeBatchTransferAcceptanceCheck(msg.sender, from, to, ids, amounts, data);
    }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}
    

}