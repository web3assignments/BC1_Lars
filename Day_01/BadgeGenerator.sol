pragma solidity 0.5.12;

contract BadgeGenerator {

  struct Badge {
    uint256 id;
    string metadataUrl;
    address owner;
  }

  address public owner;
  uint256 public badgeCount;

  mapping(uint256 => Badge) public badges;
  mapping(address => bool) public creators;

  constructor() public {
    // set owner of contract
    owner = msg.sender;
    // add owner as creator
    creators[msg.sender] = true;
  }

  modifier ownerOnly() {
    require(msg.sender == owner, 'You are not the owner');
    _;
  }

  modifier creatorOnly() {
    require(creators[msg.sender], 'You are not a badge creator');
    _;
  }

  modifier badgeOwnerOnly(uint256 _badgeId) {
    Badge storage badge = badges[_badgeId];
    require(badge.owner == msg.sender);
    _;
  }

  function addCreator(address _address) public ownerOnly {
    creators[_address] = true;
  }

  function removeCreator(address _address) public ownerOnly {
    creators[_address] = false;
  }

  // Creates a new token type and assigns _initialSupply to minter
  function createBadge(string memory _metadataUrl) public creatorOnly returns (uint256 badgeId) {
    require(badgeCount >= 0, 'invalid badgeCount');

    badges[badgeCount] = Badge(badgeCount, _metadataUrl, msg.sender);
    badgeCount++;

    return badgeCount -1;
  }
}
