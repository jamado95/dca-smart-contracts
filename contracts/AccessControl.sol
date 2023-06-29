// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0;

contract AccessControl {

    address private owner;
    mapping(address => bool) public Allowed;

    constructor() {
        owner = msg.sender;
        Allowed[msg.sender] = true;
    }

    modifier isOwner() {
        require(msg.sender == owner, "ERR_NOT_OWNER");
        _;
    }

    modifier isAllowed() {
        require(Allowed[msg.sender] == true, "ERR_NOT_ALLOWED");
        _;
    }

    function allowAccess(address cli)
        isOwner
        public
    {
        Allowed[cli] = true;
    }

    function revokeAccess(address cli)
        isOwner
        public
    {
        require(cli != owner, "ERR_IS_OWNER");
        Allowed[cli] = false;
    }
    
    function transferOwnership(address newOwner)
        isOwner
        public
    {
        require(newOwner != address(0), "ERR_ZERO_ADDR");
        require(newOwner != owner, "ERR_IS_OWNER");
        Allowed[owner] = false;
        Allowed[newOwner] = true;
        owner = newOwner;
    }
}