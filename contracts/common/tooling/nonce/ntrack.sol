// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract NonceTracker {
    error NonceAlreadyConsumed(uint128 sourceChain_, uint128 nonce_);

    mapping(uint256 => bool) private _usedNonces;

    function isNonceConsumed(
        uint128 sourceChain_,
        uint128 nonce_
    ) public view returns (bool) {
        return _isNonceConsumed(sourceChain_, nonce_);
    }

    function _isNonceConsumed(
        uint128 sourceChain_,
        uint128 nonce_
    ) internal view returns (bool) {
        uint256 n = _formatNonce(sourceChain_, nonce_);
        return _usedNonces[n];
    }

    function _consumeNonce(uint128 sourceChain_, uint128 nonce_) internal {
        uint256 n = _formatNonce(sourceChain_, nonce_);
        if (_usedNonces[n]) {
            revert NonceAlreadyConsumed(sourceChain_, nonce_);
        }
        _usedNonces[n] = true;
    }

    function _formatNonce(
        uint128 sourceChain_,
        uint128 nonce_
    ) private pure returns (uint256 n) {
        unchecked {
            // safe since both inputs are 128 bits
            n = (sourceChain_ << 128) | nonce_;
        }
        return n;
    }
}
