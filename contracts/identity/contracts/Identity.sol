// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './ClaimHolder.sol';

/**
 * @dev NOTE: This contract exists as a convenience for deploying an identity with
 * some 'pre-signed' claims. If you don't care about that, just use ClaimHolder
 * instead.
 */

contract Identity is ClaimHolder {

    constructor (
        uint256[] memory _claimType,
        uint256[] memory _scheme,
        address[] memory _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri,
        uint256[] memory _sigSizes,
        uint256[] memory dataSizes,
        uint256[] memory uriSizes
    )
    
    {
        bytes32 claimId;
        uint offset = 0;
        uint uoffset = 0;
        uint doffset = 0;

        for (uint i = 0; i < _claimType.length; i++) {

            claimId = keccak256(abi.encode(_issuer[i], _claimType[i]));

            claims[claimId] = Claim(
                _claimType[i],
                _scheme[i],
                _issuer[i],
                getBytes(_signature, offset, _sigSizes[i]),
                getBytes(_data, doffset, dataSizes[i]),
                getString(_uri, uoffset, uriSizes[i])
            );

            offset += _sigSizes[i];
            uoffset += uriSizes[i];
            doffset += dataSizes[i];

            emit ClaimAdded(
                claimId,
                claims[claimId].claimType,
                claims[claimId].scheme,
                claims[claimId].issuer,
                claims[claimId].signature,
                claims[claimId].data,
                claims[claimId].uri
            );
        }
    }

    function getBytes(bytes memory _str, uint256 _offset, uint256 _length) private pure returns (bytes memory) {
        bytes memory sig = new bytes(_length);
        uint256 j = 0;
        for (uint256 k = _offset; k< _offset + _length; k++) {
          sig[j] = _str[k];
          j++;
        }
        return sig;
    }

    function getString(string memory _str, uint256 _offset, uint256 _length) private pure returns (string memory) {
        bytes memory strBytes = bytes(_str);
        bytes memory sig = new bytes(_length);
        uint256 j = 0;
        for (uint256 k = _offset; k< _offset + _length; k++) {
          sig[j] = strBytes[k];
          j++;
        }
        return string(sig);
    }
}