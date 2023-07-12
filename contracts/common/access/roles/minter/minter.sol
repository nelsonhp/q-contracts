// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MinterRole
 * @author Hunter Prendergast
 * @notice MinterRole contract implements the storage, events, and errors
 * for an inheritable minter role. The inheriting contract must implement
 * the logic for the minter role. Specifically, the inheriting contract
 * must implement the changeMinter and LockMinter functions.
 *
 * The inheriting contract must also call the _setMinter function in its
 * constructor/initilization function.
 */
abstract contract MinterRole {
    event MinterChange(address newMinter);

    error NotMinter();
    error MinterLocked();

    address private _minter;
    bool private _minterLocked;

    modifier onlyMinter() {
        if (msg.sender != _minter) {
            revert NotMinter();
        }
        _;
    }

    function minter() public view returns (address) {
        return _minter;
    }

    function minterIsLocked() public view returns (bool) {
        return _minterLocked;
    }

    function _setMinter(address newMinter_) internal {
        if (_minterLocked) {
            revert MinterLocked();
        }
        _minter = newMinter_;
        emit MinterChange(newMinter_);
    }

    function _lockMinter() internal {
        _minterLocked = true;
    }
}
