// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "./Ownable.sol";

contract Mortal is Ownable {
    event deleteEvent(address contracAddress);

    function destroy() public payable ownerOnly {
        emit deleteEvent(address(this));
        selfdestruct(msg.sender);
    }

    function destroyAndSend(address payable _recipient) public ownerOnly {
        selfdestruct(_recipient);
    }
}

