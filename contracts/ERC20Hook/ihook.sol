// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20HookLogic {
    function beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) external returns (uint256 fee, bool isAfterHookRequired);

    function afterTokenTransfer(
        address from_,
        address to_,
        uint256 amount_,
        uint256 fee_
    ) external;
}
