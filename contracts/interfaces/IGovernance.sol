// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import './ISignatures.sol';


interface IGovernance is ISignatures {
    // Returns the access level of wallet. Values range from [0, 3]
    function AccessLevel(address wallet) external view returns(uint8);
    
    // Returns currently set threshold for governance operations
    function Threshold() external view returns(uint8);
    
    // Returns current governance nonce
    function Nonce() external view returns(uint256);

    // Updates governance threshold. Requires multi-sig
    function updateGovernance(uint8 _threshold, MultiSig calldata msig) external;
    
    // Updates target's access level. Requires multi-sig
    function updateAccessLevel(address target, uint8 level, MultiSig calldata msig) external;
}