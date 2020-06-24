pragma solidity ^0.6.0;

contract Privilege {

    enum Privileges {USER, ADMIN, OWNER}
    mapping(address => Privileges) userPrivileges;

    constructor() public {
        userPrivileges[msg.sender] = Privileges.OWNER;
    }

    modifier minimumPrivilege(Privileges privilege) {
        Privileges senderPrivilege = userPrivileges[msg.sender];

        if(privilege == Privileges.USER && senderPrivilege != Privileges.ADMIN && senderPrivilege != Privileges.OWNER) {
            userPrivileges[msg.sender] = Privileges.USER;
        }

        require (privilege <= senderPrivilege, "You do not have the privilege to use this function");
        _;
    }

    function setPrivilege(Privileges _privilege, address _userAddress) public minimumPrivilege(Privileges.ADMIN) {
        userPrivileges[_userAddress] = _privilege;
    }

    function getPrivilege() public view returns (Privileges) {
        return userPrivileges[msg.sender];
    }


}
