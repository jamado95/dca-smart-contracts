// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import'./interfaces/IWalliDV2dCA.sol';
import './interfaces/IWalliDV2Factory.sol';
import'./interfaces/IGovernance.sol';

contract WalliDV2Verifier {
    IWalliDV2Factory factory;

    constructor(address _factory) {
         factory = IWalliDV2Factory(_factory);
    }

    function verifyCredential(address _dca, bytes32 credentialHash, uint256 templateID, bytes32 templateHash, uint8 sigV, bytes32 sigR, bytes32 sigS)
        external
        view
    {
        // Verify _dca corresponds to valid dCA contract
        require(factory.isWalliDV2dCA(_dca), 'ERR_INVALID_DCA');

        IWalliDV2dCA dca = IWalliDV2dCA(_dca);

        // Verify if template valid
        bytes32 template = keccak256(abi.encode(templateID, templateHash));
        require(dca.Templates(template) == 1, 'ERR_INVALID_TEMP');

        // Verify if credential is revoked
        bytes32 credential = keccak256(abi.encode(credentialHash, templateID, templateHash));
        require(!dca.RevokedCredentials(credential), 'ERR_REVOKED_CRED');

        //Verify if credential signer is, or was a valid admin/manager of dca
        address signer = ecrecover(credential, sigV, sigR, sigS);
        require(dca.AccessLevel(signer) > 0, 'ERR_INVALID_SIGNER');
    }
}