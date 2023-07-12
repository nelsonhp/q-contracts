// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct GenericTokenConfig {
        uint8 decimals;
        address burner;
        address minter;
        address hook;
        string name;
        string symbol;
    }
