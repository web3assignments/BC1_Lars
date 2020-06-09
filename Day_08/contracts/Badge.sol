pragma solidity ^0.5.0;

contract Badge {

    uint256 id;
    address owner;

    constructor(uint256 _id, address _owner) public {
        id = _id;
        owner = _owner;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, 'You are not the owner');
        _;
    }

    function destroy() public ownerOnly {
        selfdestruct(msg.sender);
    }
}
