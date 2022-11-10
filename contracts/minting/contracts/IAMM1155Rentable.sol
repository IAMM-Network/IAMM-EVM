// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

import "./IAMM1155.sol";
import "./interfaces/IERC4907.sol";

contract IAMM1155Rentable is IAMM1155 {
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping (uint256  => mapping(uint256 => UserInfo)) internal _users;

    
    constructor(
        string memory collectionName,
        string memory collectionSymbol,
        uint8 _priceInOperationToken,
        uint248 _maxMintPerBuy,
        address _operationTokenContract,
        address _creatorWallet,
        string memory initMetadataRoot,
        uint8 _operationToken,
        bool _usinPromoters
    )
        IAMM1155(
            collectionName,
            collectionSymbol,
            _priceInOperationToken,
            _maxMintPerBuy,
            _operationTokenContract,
            _creatorWallet,
            initMetadataRoot,
            _operationToken,
            _usinPromoters
        )
    {}

    // Logged when the user of an NFT is changed or expires is changed
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(
        uint256 indexed id,
        uint256 indexed num,
        address indexed user,
        uint64 expires
    );

    function _isApprovedOrOwner(address from, uint256 id) internal view returns (bool) {
        return balanceOf(from, id) > 0;
    }

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(
        uint256 id,
        uint256 num,
        address user,
        uint64 expires
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, id),
            "IAMM155Rentable: transfer caller is not owner nor approved"
        );
        UserInfo storage info = _users[id][num];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(id, user, expires);
    }


    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param id The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 id) public view virtual returns(address){
        if( uint256(_users[id].expires) >=  block.timestamp){
            return  _users[id].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _users[tokenId].expires;
    }

     /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256[] ids,
        uint256[] amounts,
        bytes memory data
    ) internal virtual override{
        super._beforeTokenTransfer(msg.sender, from, to, ids, amounts, data);

        if (from != to && _users[ids].user != address(0)) {
            delete _users[ids];
            emit UpdateUser(ids, address(0), 0);
        }
    }
}
