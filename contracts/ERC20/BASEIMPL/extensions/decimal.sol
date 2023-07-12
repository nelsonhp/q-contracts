// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract DecimalOveride {
    uint8 private _decimals;

    function _getDecimals() internal view returns (uint8) {
        return _decimals;
    }

    function _setDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
}
