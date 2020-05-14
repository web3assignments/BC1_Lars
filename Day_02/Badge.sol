pragma solidity ^0.5.0;

import "./ERC1155Full.sol";

contract Badge is ERC1155 {
  address public owner;

  mapping(address => bool) public _canCreate;
  mapping(uint256 => address) public _tokenCreators;

  // id => creators
  mapping(uint256 => address) public creators;

  // A nonce to ensure we have a unique id each time we mint.
  uint256 public nonce;

  constructor() public {
    // set owner of contract
    owner = msg.sender;
    // add owner as creator
    _canCreate[msg.sender] = true;
  }

  modifier _ownerOnly() {
    require(msg.sender == owner, "Only the owner of the contract is allowed to use this function");
    _;
  }

  modifier _creatorOnly() {
    require(_canCreate[msg.sender], "Only creators can create new tokens");
    _;
  }

  modifier _tokenCreatorOnly(uint256 _id) {
    require(_tokenCreators[_id] == msg.sender, 'Only the token creator can mint new tokens');
    _;
  }

  function addCreator(address _address) external _ownerOnly() {
    _canCreate[_address] = true;
  }

  function removeCreator(address _address) external _ownerOnly() {
    _canCreate[_address] = false;
  }

  // Creates a new token type and assings _initialSupply to minter
  function create(uint256 _initialSupply, string calldata _uri) external _creatorOnly() returns (uint256 _id)  {
    require(nonce > 0, 'invalid nonce');

    _id = ++nonce;
    _tokenCreators[_id] = msg.sender;
    balances[_id][msg.sender] = _initialSupply;

    // Transfer event with mint semantic
    emit TransferSingle(msg.sender, address(0x0), msg.sender, _id, _initialSupply);

    if (bytes(_uri).length > 0)
      emit URI(_uri, _id);
  }

  function mint(uint256 _id, address _to, uint256 _quantity) external _tokenCreatorOnly(_id) {
    require(_id > 0 && _id < nonce, 'invalid id');
    require(_quantity > 0, 'quantity must be higher than 0');
    require(_to == address(0x0), 'invalid address');

    // Grant the items to the caller
    balances[_id][_to] = _quantity.add(balances[_id][_to]);

    // Emit the Transfer/Mint event.
    // the 0x0 source address implies a mint
    // It will also provide the circulating supply info.
    emit TransferSingle(msg.sender, address(0x0), _to, _id, _quantity);

    if (_to.isContract()) {
      _doSafeTransferAcceptanceCheck(msg.sender, msg.sender, _to, _id, _quantity, '');
    }
  }

  function setURI(string calldata _uri, uint256 _id) external _tokenCreatorOnly(_id) {
    emit URI(_uri, _id);
  }

  function canCreateToken() public view returns (bool) {
    return _canCreate[msg.sender];
  }

}
