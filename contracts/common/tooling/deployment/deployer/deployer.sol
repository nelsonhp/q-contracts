// SPDX-License-Identifier: MIT-open-group
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Address.sol";

abstract contract CreateFactory {
    using Address for address;

    /**
     * @dev Not enough balance for performing a deployment.
     */
    error CreateInsufficientBalance(uint256 balance, uint256 needed);

    /**
     * @dev There's no code to deploy.
     */
    error CreateEmptyBytecode();

    /**
     * @dev The deployment failed.
     */
    error CreateFailedDeployment();

    /**
     * @dev Deploys a contract using `CREATE`.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function _deploy(
        uint256 amount,
        bytes memory bytecode_
    ) internal returns (address addr) {
        if (address(this).balance < amount) {
            revert CreateInsufficientBalance(address(this).balance, amount);
        }
        if (bytecode_.length == 0) {
            revert CreateEmptyBytecode();
        }
        /// @solidity memory-safe-assembly
        assembly {
            addr := create(amount, add(bytecode_, 0x20), mload(bytecode_))
        }
        if (addr == address(0)) {
            revert CreateFailedDeployment();
        }
        if (!addr.isContract()) {
            revert CreateFailedDeployment();
        }
    }

    function _initalizeDeployed(address addr_, bytes memory payload_) internal {
        addr_.functionCall(payload_);
    }
}
