// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

abstract contract BridgeEvents {
    
    event Deposit(
        address indexed token,
        address indexed to,
        uint256 indexed amount,
        uint256 nonce,
        uint256 nativeChain,
        uint256 destChain
    );

    event Withdrawal(
        address indexed token,
        address indexed to,
        uint256 indexed amount,
        uint256 nonce,
        uint256 nativeChain
    );
}