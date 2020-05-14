pragma solidity ^0.5.0;

import "./ERC1155Full.sol";

contract Badge is ERC1155 {

  // A nonce to ensure we have a unique id each time we mint.
  uint256 public nonce;

  constructor() public {
  }

  // Creates a new token type and assings _initialSupply to minter
  function create(uint256 _initialSupply, string calldata _uri) external returns (uint256 _id)  {

    _id = ++nonce;
    _tokenCreators[_id] = msg.sender;
    balances[_id][msg.sender] = _initialSupply;

    // Transfer event with mint semantic
    emit TransferSingle(msg.sender, address(0x0), msg.sender, _id, _initialSupply);

    if (bytes(_uri).length > 0)
      emit URI(_uri, _id);
  }

  function mint(uint256 _id, address _to, uint256 _quantity) external _tokenCreatorOnly(_id) {
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
}
