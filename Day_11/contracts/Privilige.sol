pragma solidity ^0.6.0;

contract Privilige {

    enum Priviliges {USER, ADMIN, OWNER}
    mapping(address => Priviliges) userPriviliges;

    constructor() public {
        userPriviliges[msg.sender] = Priviliges.OWNER;
    }

    modifier minimumPrivilige(Priviliges privilige) {
        Priviliges senderPrivilige = userPriviliges[msg.sender];

        require (privilige <= senderPrivilige, "You do not have the privilige to use this function");
        _;
    }

    function setUserPrivilige(address _address) public {
        userPriviliges[_address] = Priviliges.USER;
    }

    function setPrivilige(Priviliges _privilige, address _userAddress) public minimumPrivilige(Priviliges.ADMIN) {
        userPriviliges[_userAddress] = _privilige;
    }

    function getPrivilige() public view returns (Priviliges) {
        return userPriviliges[msg.sender];
    }


}
