// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "./Badge.sol";
import "./Mortal.sol";

contract BadgeFactory is Mortal {
    bytes mmcode = type(Badge).creationCode;
    Badge public deployedBadge;

    mapping(address => bool) public creators;

    event badgeCreated(Badge badge);
    event addedCreator(address _address);
    event removedCreator(address _address);

    constructor() public {
    }

    function SetDeployedBadgeUrl() public view returns (string memory) {
        return deployedBadge.metadataUrl();
    }

    function DestroyDeployedBadge() public {
        deployedBadge.destroy();
    }


    modifier creatorOnly() {
        require(creators[msg.sender], 'You are not a badge creator');
        _;
    }

    function addCreator(address _address) public ownerOnly {
        creators[_address] = true;
        emit addedCreator(_address);
    }

    function removeCreator(address _address) public ownerOnly {
        creators[_address] = false;
        emit removedCreator(_address);
    }

    function DeployViaCreate() public returns (Badge){
        deployedBadge=Badge(Create(mmcode));
        deployedBadge.SetUrl("badge-test.json");
        return deployedBadge;
    }

    function Create(bytes memory code) private returns(address addr) {
        assembly {
            addr := create(0, add(code, 0x20), mload(code))
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }
}
