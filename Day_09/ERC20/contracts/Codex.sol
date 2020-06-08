pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Codex is ERC20 {

    address private owner;

    constructor(string memory _name, string  memory _symbol) ERC20(_name, _symbol) public {
        owner = msg.sender;

        _mint(msg.sender, 1000 * (10 ** uint256(18)));
    }

}
