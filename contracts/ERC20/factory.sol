// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/tooling/deployment/factory/factory.sol";
import "contracts/common/access/roles/admin/admin.sol";
import "contracts/ERC20/BASEIMPL/ERC20.sol";

contract ERC20Factory is GenericFactory, AdminRole {
    constructor() AdminRole(msg.sender) {}

    function deploy(GenericTokenConfig calldata config_) public onlyAdmin returns (address addr) {
        addr = _deploy(config_.symbol);
        GenericToken(addr).initialize(config_);
    }

    function _code() internal pure override returns (bytes memory) {
        return type(GenericToken).creationCode;
    }
}
