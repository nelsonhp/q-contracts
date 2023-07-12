// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Create2.sol";

contract GenericFactory {
    bytes32 private immutable _initHash;

    constructor() {
        _initHash = keccak256(_code());
    }

    function addressFor(
        string calldata symbol_
    ) public view returns (address addr) {
        addr = _address(symbol_);
    }

    function _deploy(string memory symbol_) internal returns (address addr) {
        bytes32 salt = _makeSalt(symbol_);
        bytes memory code = _code();
        addr = Create2.deploy(0, salt, code);
    }

    function _address(
        string memory symbol_
    ) internal view returns (address addr) {
        bytes32 salt = _makeSalt(symbol_);
        addr = Create2.computeAddress(salt, _initHash);
    }

    function _makeSalt(
        string memory symbol_
    ) internal pure returns (bytes32 salt) {
        salt = keccak256(abi.encodePacked(symbol_));
    }

    function _code() internal pure virtual returns (bytes memory) {}
}
