// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import './ISignatures.sol';


interface IWalliDV2Factory is ISignatures {
    
    // Returns TRUE if dca is a valid dCA created by this factory. Returns false otherwise
    function isWalliDV2dCA(address dca) external view returns(bool);
    
    // Deploys a new WalliDV2dCA contract with provided name and msg.sender as the sole admin
    function createDCA(uint256 id, address admin) external returns(address dca);
    
    // Destroys the dca WalliDV2dCA contract. Requires multi-sig
    function destroyDCA(address dca, MultiSig calldata msig) external;
}