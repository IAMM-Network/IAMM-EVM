// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './ClaimHolder.sol';

contract ClaimVerifier {

  event ClaimValid(ClaimHolder _identity, uint256 claimType);
  event ClaimInvalid(ClaimHolder _identity, uint256 claimType);

  ClaimHolder public trustedClaimHolder;

  constructor (address _trustedClaimHolder) {
    trustedClaimHolder = ClaimHolder(_trustedClaimHolder);
  }

  function checkClaim(ClaimHolder _identity, uint256 claimType) public view returns (bool claimValid) {
    return claimIsValid(_identity, claimType);
  }

  function claimIsValid(ClaimHolder _identity, uint256 claimType) public view returns (bool claimValid) {
    uint256 foundClaimType;
    uint256 scheme;
    address issuer;
    bytes memory sig;
    bytes memory data;

    //Construct claimId (identifier + claim type)
    //This is packed because always will be de same expected keccak256 hash 
    //if trustedClaimHolder and ClaimType do no change
    bytes32 claimId = keccak256(
      abi.encodePacked(trustedClaimHolder, claimType)
    );

    //Fetch claim from user
    //For now URI is skipped (last parameter)
    (foundClaimType, scheme, issuer, sig, data,) = _identity.getClaim(claimId);

    //Get hash of _identity + claimType + data
    bytes32 dataHash = keccak256(
      abi.encode(_identity, claimType, data)
    );

    //get hash of Message + DataHash
    bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));

    // Recover address of data signer
    address recovered = getRecoveredAddress(sig, prefixedHash);

    // Take hash of recovered address
    bytes32 hashedAddr = keccak256(abi.encodePacked(recovered));

    // Does the trusted identifier have they key which signed the user's claim?
    return trustedClaimHolder.keyHasPurpose(hashedAddr, 3);
  }

  function getRecoveredAddress(bytes memory sig, bytes32 dataHash) public pure returns (address addr) {
      if (sig.length != 65) return address(0x0);

      bytes32 ra;
      bytes32 sa;
      uint8 va;

      // Divide the signature in r, s and v variables
      assembly {
        ra := mload(add(sig, 32))
        sa := mload(add(sig, 64))
        va := byte(0, mload(add(sig, 96)))
      }

      if (va < 27) va += 27;

      address recoveredAddress = ecrecover(dataHash, va, ra, sa);

      return (recoveredAddress);
  }

}