// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import './interfaces/IWalliDBalances.sol';
import './interfaces/IWalliDV2dCA.sol';
import './interfaces/IGovernance.sol';


contract WalliDV2dCA is IWalliDV2dCA {
    
    address immutable factory;
    uint256 public override ID;
    mapping (bytes32 => uint8) public override Templates;
    mapping (bytes32 => bool) public override RevokedCredentials;
    mapping (address => uint8) public override AccessLevel;
    uint8 public override Threshold;
    uint256 public override Nonce;
    
    modifier isAdmin(Sig calldata sig) {
        (, uint8 level) = resolveSig(sig);
        require(level == 2, 'ERR_NOT_ADMIN');
        Nonce += 1;
        _;
    }

    modifier isManager(Sig calldata sig) {
        (, uint8 level) = resolveSig(sig);
        require(level < 3, 'ERR_NOT_MANAGER');
        Nonce += 1;
        _;
    }

    modifier isAdminMultiSig(MultiSig calldata msig) {
        (, uint8[] memory levels) = resolveMultiSig(msig);
        for (uint i = 0; i < levels.length; i++) require(levels[i] == 2, 'ERR_MULTI_SIG');
        Nonce += 1;
        _;
    }
    
    constructor(address _owner, uint256 id)
    {
        factory = msg.sender;
        ID = id;
        AccessLevel[_owner] = 2;
        Threshold = 1;
    }
    
    // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
    function resolveSig(Sig calldata sig)
        public
        view
        returns (address recovered, uint8 level)
    {
        bytes32 txHash = keccak256(abi.encode(byte(0x19), byte(0), address(this), sig.data, Nonce));
        recovered = ecrecover(txHash, sig.sigV, sig.sigR, sig.sigS);
        level = AccessLevel[recovered];
    }
    
    // Follows ERC191 signature scheme: https://github.com/ethereum/EIPs/issues/191
    function resolveMultiSig(MultiSig calldata msig)
        public
        view
        returns (address[] memory recovered, uint8[] memory levels)
    {
        uint len = msig.sigR.length;
        require(len == Threshold);
        require(msig.sigR.length == len && msig.sigS.length == len && msig.sigV.length == len);
        bytes32 txHash = keccak256(abi.encode(byte(0x19), byte(0), address(this), msig.data, Nonce));
        recovered = new address[](len);
        levels = new uint8[](len);
        for (uint i = 0; i < Threshold; i++) {
            recovered[i] = ecrecover(txHash, msig.sigV[i], msig.sigR[i], msig.sigS[i]);
            levels[i] = AccessLevel[recovered[i]];
        }
    }
    
    function createTemplate(uint256 id, bytes32 hash, Sig calldata sig)
        isAdmin(sig)
        external
        override
    {
        bytes32 template = keccak256(abi.encode(id, hash));
        require(Templates[template] == 0, 'ERR_CREATE_TEMP'); // only if template doesn't exist
        Templates[template] = 1;
        IWalliDBalances(factory).executeBalance(0x01);
    }

    function revokeTemplate(uint256 id, bytes32 hash, Sig calldata sig)
        isAdmin(sig)
        external
        override
    {
        bytes32 template = keccak256(abi.encode(id, hash));
        require(Templates[template] == 1); // only if template already exists
        Templates[template] = 2;
        IWalliDBalances(factory).executeBalance(0x02);
    }
    
    function revokeCredential(bytes32 credentialHash, uint256 templateID, bytes32 templateHash, uint8 sigV, bytes32 sigR, bytes32 sigS, Sig calldata sig)
        isManager(sig)
        public
        override
    {   
        bytes32 credential = keccak256(abi.encode(credentialHash, templateID, templateHash));
        address signer = ecrecover(credential, sigV, sigR, sigS);
        require(AccessLevel[signer] > 0, 'ERR_UNKNOWN_SIGNER');
        RevokedCredentials[credential] = true;
        IWalliDBalances(factory).executeBalance(0x03);
    }
    
    function updateGovernance(uint8 _threshold, MultiSig calldata msig)
        isAdminMultiSig(msig)
        public
        override
    {
        require(Threshold > 0);
        Threshold = _threshold;
        IWalliDBalances(factory).executeBalance(0x00);
    }
    
    function updateAccessLevel(address target, uint8 level, MultiSig calldata msig)
        isAdminMultiSig(msig)
        public
        override
    {
        // Block update if target is revoked i.e access level equal to 3
        require(level > 0 && level < 4, 'ERR_INVALID_LEVEL');
        require(AccessLevel[target] != 3, 'ERR_TARGET_REVOKED');
        AccessLevel[target] = level;
        IWalliDBalances(factory).executeBalance(0x00);
    }
    
    function destroy(MultiSig calldata msig)
        isAdminMultiSig(msig)
        public
        override
    {
        require(msg.sender == factory);
        selfdestruct(address(0));
    }
}