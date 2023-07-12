// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/access/roles/minter/minter.sol";

contract MockMinter is MinterRole {
    constructor(address a_) {
        _setMinter(a_);
    }

    function changeMinter(address newMinter_) public {
        _setMinter(newMinter_);
    }

    function lockMinter() public {
        _lockMinter();
    }

    function protected() public view onlyMinter returns (bool) {
        return true;
    }
}
