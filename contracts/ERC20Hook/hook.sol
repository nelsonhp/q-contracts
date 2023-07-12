// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/ERC20Hook/ihook.sol";

import "contracts/common/access/roles/admin/admin.sol";

import "contracts/common/access/roles/token/token.sol";

/**
 * @title ERC20HookBase
 * @author Hunter Prendergast
 * @notice This contract provides a minimal tmplate from which custom
 * hook logic contracts may be built.
 */
abstract contract ERC20HookLogic is
    IERC20HookLogic,
    AdminRole,
    TokenRole {
    error InvalidTransfer();

    constructor(address admin_, address token_) {
        AdminRole(admin_);
        _setTokenRole(token_);
    }

    function changeToken(address newToken_) public onlyAdmin {
        _setTokenRole(newToken_);
    }

    function lockToken() public onlyAdmin {
        _lockToken();
    }

    function _isMint(address from_, address to_) internal pure returns (bool) {
        return (from_ == address(0)) && (to_ != address(0));
    }

    function _isBurn(address from_, address to_) internal pure returns (bool) {
        return (from_ != address(0)) && (to_ == address(0));
    }

    function _isTransfer(
        address from_,
        address to_
    ) internal pure returns (bool) {
        return (from_ != address(0)) && (to_ != address(0));
    }

    function beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) public virtual returns (uint256 fee, bool isAfterHookRequired) {
        if (_isMint(from_, to_)) {
            fee = _beforeMint(to_, amount_);
        } else if (_isBurn(from_, to_)) {
            fee = _beforeBurn(from_, amount_);
        } else if (_isTransfer(from_, to_)) {
            fee = _beforeTransfer(from_, to_, amount_);
        } else {
            revert InvalidTransfer();
        }
        return (fee, _isAfterHookRequired());
    }

    function afterTokenTransfer(
        address from_,
        address to_,
        uint256 amount_,
        uint256 fee_
    ) public virtual {
        if (_isMint(from_, to_)) {
            _afterMint(to_, amount_, fee_);
        } else if (_isBurn(from_, to_)) {
            _afterBurn(from_, amount_, fee_);
        } else if (_isTransfer(from_, to_)) {
            _afterTransfer(from_, to_, amount_, fee_);
        } else {
            revert InvalidTransfer();
        }
    }

    function _isAfterHookRequired() internal pure virtual returns (bool) {
        return true;
    }

    function _beforeMint(
        address, //to_,
        uint256 //amount_
    ) internal virtual returns (uint256 fee) {
        return 0;
    }

    function _beforeBurn(
        address, // from_,
        uint256 // amount_
    ) internal virtual returns (uint256 fee) {
        return 0;
    }

    function _beforeTransfer(
        address, // from_,
        address, // to_,
        uint256 // amount_
    ) internal virtual returns (uint256 fee) {
        return 0;
    }

    function _afterMint(
        address, // to_,
        uint256, // amount_,
        uint256 // fee_
    ) internal virtual {
        return;
    }

    function _afterBurn(
        address, // from_,
        uint256, // amount_,
        uint256 // fee_
    ) internal virtual {
        return;
    }

    function _afterTransfer(
        address, // from_,
        address, // to_,
        uint256, // amount_,
        uint256 // fee_
    ) internal virtual {
        return;
    }
}
