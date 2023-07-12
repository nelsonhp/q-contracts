// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title FeeCollectorRole
 * @author Hunter Prendergast
 * @notice FeeCollectorRole contract implements the storage, events, and errors
 * for an inheritable fee collector role. The inheriting contract must implement
 * the logic for the fee collector role. Specifically, the inheriting contract
 * must implement the changeFeeCollector and LockFeeCollector functions.
 *
 * The inheriting contract must also call the _setFeeCollector function in its
 * constructor/initilization function.
 */
contract FeeCollectorRole {
    event FeeCollectorChange(address newFeeCollector_);

    error FeeCollectorLocked();
    error NotFeeCollector(address account);

    address private _feeCollector;
    bool private _feeCollectorLocked;

    modifier onlyFeeCollector() {
        if (msg.sender != _feeCollector) {
            revert NotFeeCollector(msg.sender);
        }
        _;
    }

    function feeCollector() public view returns (address) {
        return _feeCollector;
    }

    function feeCollectorIsLocked() public view returns (bool) {
        return _feeCollectorLocked;
    }

    function _setFeeCollector(address newFeeCollector_) internal {
        if (_feeCollectorLocked) {
            revert FeeCollectorLocked();
        }
        _feeCollector = newFeeCollector_;
        emit FeeCollectorChange(newFeeCollector_);
    }

    function _lockFeeCollector() internal {
        _feeCollectorLocked = true;
    }
}
