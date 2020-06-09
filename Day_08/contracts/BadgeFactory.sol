pragma solidity ^0.5.0;

import "Badge.sol";

contract BadgeFactory {

    Badge[] public badges;
    address owner;

    mapping(address => bool) public creators;

    event badgeCreated(Badge badge);
    event addedCreator(address _address);
    event removedCreator(address _address);

    constructor() public {
        // set owner of contract
        owner = msg.sender;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, 'You are not the owner');
        _;
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

    // Creates a new token type and assigns _initialSupply to minter
    function createBadge() public {
        Badge newBadge = new Badge(badges.length, msg.sender);
        badges.push(newBadge);
        emit badgeCreated(newBadge);

    }

    function getDeployedChildContracts() public view returns (Badge[] memory) {
        return badges;
    }

    function getContractCount() public view returns(uint contractCount) {
        return badges.length;
    }
}
