// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/access/targets/hook/hook.sol";

contract MockERC20Hook is ERC20HookTarget {
    constructor(address a_) {
        _setERC20Hook(a_);
    }

    function changeERC20Hook(address newERC20Hook_) public {
        _setERC20Hook(newERC20Hook_);
    }

    function lockERC20Hook() public {
        _lockERC20Hook();
    }
}
