// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;


// Defines SIg, MultiSig structures for packaging signature data
interface ISignatures {
    struct Sig {
        bytes32 data;
        uint8 sigV;
        bytes32 sigR;
        bytes32 sigS;
    }
    
    struct MultiSig {
        bytes32 data;
        uint8[] sigV;
        bytes32[] sigR;
        bytes32[] sigS;
    }
}