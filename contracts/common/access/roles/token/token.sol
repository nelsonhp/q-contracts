// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TokenRole
 * @author Hunter Prendergast
 * @notice contract implements the storage, events, and errors
 * for an inheritable TokenRole. This role is intended to protect
 * against any contract other than the actual token from invoking
 * the hooks.
 */
abstract contract TokenRole {
    event TokenChange(address newToken_);

    error NotToken();
    error TokenLocked();

    address private _token;
    bool private _tokenLocked;

    modifier onlyToken() {
        if (msg.sender != _token) {
            revert NotToken();
        }
        _;
    }

    function token() public view returns (address) {
        return _token;
    }

    function _setTokenRole(address newToken_) internal {
        if (_tokenLocked) {
            revert TokenLocked();
        }
        _token = newToken_;
        emit TokenChange(newToken_);
    }

    function _lockToken() internal {
        _tokenLocked = true;
    }
}
