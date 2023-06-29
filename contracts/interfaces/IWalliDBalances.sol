// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;


interface IWalliDBalances {
    //0x00 - Governance; 0x01 - CreateTemplate; 0x02 - RevokeTemplate; 0x03 - RevokeCredential;
    function Balances(address dca, bytes1 bal) external returns(uint256);

    function updateBalances(address _dca, uint256[4] calldata quantity) external;

    function executeBalance(bytes1 bal) external;
}