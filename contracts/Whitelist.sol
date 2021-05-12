// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelist is Ownable{
    event MemberAdded (address member);
    event MemberRemoved (address member);

    mapping (address => bool) members;

    /**
    * @dev The contract constructor
     */
    constructor() public Ownable() {}

    function isMember(address _member) public view returns(bool) {
        return members[_member];
    }

    function addMember (address _member) public onlyOwner {
        require(!isMember(_member), "Address is member already.");
        members[_member] = true;
        emit MemberAdded(_member);
    }

    function removeMember(address _member) public onlyOwner {
        require(isMember(_member), "Not member of whitelist");
        delete members[_member];
        emit MemberRemoved(_member);
    }
}