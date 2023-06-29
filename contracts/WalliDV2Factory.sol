// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;
pragma experimental ABIEncoderV2;

import './interfaces/IWalliDV2Factory.sol';
import './interfaces/IWalliDBalances.sol';
import './WalliDV2dCA.sol';
import './AccessControl.sol';


contract WalliDV2Factory is IWalliDV2Factory, IWalliDBalances, AccessControl {
    
    mapping (address => bool) public override isWalliDV2dCA;
    mapping (address => mapping (bytes1 => uint256)) public override Balances;
    
    event WalliDdCACreated(address indexed dca, uint256 indexed id, address admin);
    
    function createDCA(uint256 id, address admin)
        external
        override
        returns (address dca)
    {
        dca = address(new WalliDV2dCA(admin, id));
        isWalliDV2dCA[dca] = true;
        emit WalliDdCACreated(dca, id, admin);
    }
    
    function destroyDCA(address _dca, MultiSig calldata msig)
        public
        override
    {
        require(isWalliDV2dCA[_dca], 'ERR_NOT_DCA');
        IWalliDV2dCA(_dca).destroy(msig);
        isWalliDV2dCA[_dca] = false;
    }
    
    function executeBalance(bytes1 bal)
        public
        override
    {
        require(isWalliDV2dCA[msg.sender], 'ERR_NOT_DCA');
        require(Balances[msg.sender][bal] > 0, 'ERR_NO_BALANCE');
        Balances[msg.sender][bal] -= 1;
    }
    
    function updateBalances(address _dca, uint256[4] calldata quantity)
        isAllowed
        public
        override
    {
        require(isWalliDV2dCA[_dca], 'ERR_NOT_DCA');
        Balances[_dca][0x00] += quantity[0];
        Balances[_dca][0x01] += quantity[1];
        Balances[_dca][0x02] += quantity[2];
        Balances[_dca][0x03] += quantity[3];
    }
}