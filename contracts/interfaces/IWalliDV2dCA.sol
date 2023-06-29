// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import './ISignatures.sol';


interface IWalliDV2dCA is ISignatures {
    // Returns this dCA ID
    function ID() external view returns(uint256);
    
    // Returns current state of template in dCA. State can be 0 if template does not exist; 1 if template is active and 2 for a revoked template
    function Templates(bytes32 template) external view returns (uint8);
    
    // Returns TRUE if credential is revoked. Returns FALSE otherwise
    function RevokedCredentials(bytes32 credential) external view returns (bool);
    
    // Creates a new template defined by { id, hash }
    function createTemplate(uint256 id, bytes32 hash, Sig calldata sig) external;
    
    // Revokes template defined by { id, hash }
    function revokeTemplate(uint256 id, bytes32 hash, Sig calldata sig) external;
    
    // Revokes credential defined by { credentialHash, templateID, templateHash }
    function revokeCredential(bytes32 credentialHash, uint256 templateID, bytes32 templateHash, uint8 sigV, bytes32 sigR, bytes32 sigS, Sig calldata sig) external;
    
    // Destroys this dCA contract. Requires multi-sig
    function destroy(MultiSig calldata msig) external;
}