// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BurnerRole
 * @author Hunter Prendergast
 * @notice BurnerRole contract implements the storage, events, and errors
 * for an inheritable burner role. The inheriting contract must implement
 * the logic for the burner role. Specifically, the inheriting contract
 * must implement the changeBurner and LockBurner functions.
 *
 * The inheriting contract must also call the _setBurner function in its
 * constructor/initilization function.
 */
abstract contract BurnerRole {
    event BurnerChange(address newBurner_);

    error NotBurner();
    error BurnerLocked();

    address private _burner;
    bool private _burnerLocked;

    modifier onlyBurner() {
        if (msg.sender != _burner) {
            revert NotBurner();
        }
        _;
    }

    function burner() public view returns (address) {
        return _burner;
    }

    function burnerIsLocked() public view returns (bool) {
        return _burnerLocked;
    }

    function _setBurner(address newBurner_) internal {
        if (_burnerLocked) {
            revert BurnerLocked();
        }
        _burner = newBurner_;
        emit BurnerChange(newBurner_);
    }

    function _lockBurner() internal {
        _burnerLocked = true;
    }
}
