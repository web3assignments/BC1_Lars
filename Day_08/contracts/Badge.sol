// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "./Mortal.sol";

contract Badge is Mortal {

    string public metadataUrl;
    mapping(address => bool) badgeCreators;

    modifier badgeOwnerOnly {
        require(owner == msg.sender);
        _;
    }

    function SetUrl(string memory _url) public {
        metadataUrl = _url;
    }

    function addBadgeCreator(address _address) public badgeOwnerOnly() {
        badgeCreators[_address] = true;
    }

    function removeBadgeCreator(address _address) public badgeOwnerOnly() {
        badgeCreators[_address] = false;
    }

    function isBadgeCreator(address _address) public view returns (bool) {
        return badgeCreators[_address];
    }

}
