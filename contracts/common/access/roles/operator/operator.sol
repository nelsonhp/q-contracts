// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title OperatorRole
 * @author Hunter Prendergast
 * @notice OperatorRole contract implements the storage, events, and errors
 * for an inheritable Operator role. The inheriting contract must implement
 * the logic for the Operator role. Specifically, the inheriting contract
 * must implement the changeOperator and LockOperator functions.
 *
 * The inheriting contract must also call the _setOperator function in its
 * constructor/initilization function.
 */
abstract contract OperatorRole {
    event OperatorChange(address newOperator);

    error NotOperator();
    error OperatorLocked();

    address private _operator;
    bool private _operatorLocked;

    modifier onlyOperator() {
        if (msg.sender != _operator) {
            revert NotOperator();
        }
        _;
    }

    function Operator() public view returns (address) {
        return _operator;
    }

    function OperatorIsLocked() public view returns (bool) {
        return _operatorLocked;
    }

    function _setOperator(address newOperator_) internal {
        if (_operatorLocked) {
            revert OperatorLocked();
        }
        _operator = newOperator_;
        emit OperatorChange(newOperator_);
    }

    function _lockOperator() internal {
        _operatorLocked = true;
    }
}
