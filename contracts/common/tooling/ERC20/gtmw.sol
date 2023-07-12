// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// GENERIC TOKEN MIDDLEWARE

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "contracts/common/tooling/ERC20/errors.sol";

interface _AdHokBurner {
    function burnFrom(address account, uint256 amount) external returns (bool);
}

interface _AdHokMinter {
    function mintTo(address account, uint256 amount) external returns (bool);
}

interface _AdHocToken is IERC20Metadata {
    function burner() external view returns (_AdHokBurner);

    function minter() external view returns (_AdHokMinter);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

library GenericTokenMiddleware {

    struct MiddlewareData {
        _AdHocToken _token;
    }

    function _setToken(MiddlewareData storage self, address token_) internal {
        self._token = _AdHocToken(token_);
    }

    function symbol(MiddlewareData storage self) internal view returns (string memory) {
        return self._token.symbol();
    }

    function _name(MiddlewareData storage self) internal view returns (string memory) {
        return self._token.name();
    }

    function _tokenAddr(MiddlewareData storage self) internal view returns (address) {
        return address(self._token);
    }

    function _balance(MiddlewareData storage self) internal view returns (uint256) {
        return self._token.balanceOf(address(this));
    }

    function _transferFrom(MiddlewareData storage self, address from_, uint256 amount_) internal {
        if (!self._token.transferFrom(from_, address(this), amount_)) {
            revert TransferFromFailure();
        }
    }

    function _transfer(MiddlewareData storage self, address to_, uint256 amount_) internal {
        if (!self._token.transfer(to_, amount_)) {
            revert TransferFailure();
        }
    }

    function _burnFrom(MiddlewareData storage self, address from_, uint256 amount_) internal {
        _AdHokBurner burner = self._token.burner();
        if (!burner.burnFrom(from_, amount_)) {
            revert BurnFailure();
        }
    }

    function _mintTo(MiddlewareData storage self, address to_, uint256 amount_) internal {
        _AdHokMinter minter = self._token.minter();
        if (!minter.mintTo(to_, amount_)) {
            revert MintFailure();
        }
    }
}
