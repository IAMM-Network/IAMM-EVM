// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ERC735.sol";
import "./KeyHolder.sol";

contract ClaimHolder is KeyHolder, ERC735 {
    // ERC725 - Smart Contract based Account
    bytes4  private constant _INTERFACEID_ERC725X = 0x44c028fe;
    bytes4 private constant _INTERFACEID_ERC725Y = 0x714df77c;

    mapping(bytes32 => Claim) claims;
    mapping(uint256 => bytes32[]) claimsByType;

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return(interfaceId == _INTERFACEID_ERC725X || interfaceId == _INTERFACEID_ERC725Y);
    }

    function addClaim(
        uint256 _claimType,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri) public override returns (bytes32 claimRequestId) {
        bytes32 claimId = keccak256(abi.encode(_issuer, _claimType));

        if (msg.sender != address(this)) {
            require(
                keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 3),
                "Sender does not have claim signer key"
            );
        }

        if (claims[claimId].issuer != _issuer)
            claimsByType[_claimType].push(claimId);

        claims[claimId].claimType = _claimType;
        claims[claimId].scheme = _scheme;
        claims[claimId].issuer = _issuer;
        claims[claimId].signature = _signature;
        claims[claimId].data = _data;
        claims[claimId].uri = _uri;

        emit ClaimAdded(
            claimId,
            _claimType,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

    function removeClaim(bytes32 _claimId)
        public
        override
        returns (bool success) {
        if (msg.sender != address(this)) {
            require(
                keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), 1),
                "Sender does not have management key"
            );
        }

        /* uint index; */
        /* (index, ) = claimsByType[claims[_claimId].claimType].indexOf(_claimId);
        claimsByType[claims[_claimId].claimType].removeByIndex(index); */

        emit ClaimRemoved(
            _claimId,
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );

        delete claims[_claimId];
        return true;
    }

    function getClaim(bytes32 _claimId) public view override returns (
        uint256 claimType,
        uint256 scheme,
        address issuer,
        bytes memory signature,
        bytes memory data,
        string memory uri) {
        return (
            claims[_claimId].claimType,
            claims[_claimId].scheme,
            claims[_claimId].issuer,
            claims[_claimId].signature,
            claims[_claimId].data,
            claims[_claimId].uri
        );
    }

    function getClaimIdsByType(uint256 _claimType)
        public
        view
        override
        returns (bytes32[] memory claimIds) {
        return claimsByType[_claimType];
    }
}
