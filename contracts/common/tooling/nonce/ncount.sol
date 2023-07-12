// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract NonceCounter {
    uint128 private _nonce;

    function nonce() public view returns (uint128) {
        return _nonce;
    }

    function _incrementNonce() internal returns (uint128) {
        uint128 n = _nonce;
        n += 1;
        _nonce = n;
        return n;
    }
}
