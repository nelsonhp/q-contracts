// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "contracts/common/access/roles/admin/admin.sol";

import "contracts/common/access/roles/minter/minter.sol";
import "contracts/common/access/roles/burner/burner.sol";
import "contracts/common/access/roles/fee/fee.sol";


// import "contracts/common/access/roles/minter/minter.sol";
// import "contracts/common/access/roles/minter/iminter.sol";
// import "contracts/common/access/roles/burner/burner.sol";
// import "contracts/common/access/roles/admin/iadmin.sol";
// import "contracts/common/access/roles/burner/iburner.sol";
// import "contracts/common/access/roles/burner/burner.sol";
// import "contracts/common/access/roles/burner/iburner.sol";
// import "contracts/common/access/roles/fee/fee.sol";
// import "contracts/common/access/roles/fee/ifee.sol";

import "contracts/ERC20Hook/hook.sol";
import "contracts/ERC20Hook/ihook.sol";
import "contracts/ERC20/BASEIMPL/extensions/decimal.sol";

import "contracts/common/access/targets/hook/hook.sol";
import "contracts/ERC20/BASEIMPL/extensions/decimal.sol";
import "contracts/ERC20/BASEIMPL/IERC20.sol";
import "contracts/ERC20/BASEIMPL/config.sol";

/**
 * @title GenericToken
 * @author Hunter Prendergast
 * @notice This is a generic token contract that can be used as is
 * for almost any ERC20 token specification.
 *
 * @dev This token is designed to beextended through the calling of external
 * contracts during `_transfer`.
 *
 * These external calls operate in the same manner as OpenZepplin's
 * hooks, but they allow the logic to exist outside the core token logic.
 * This allows for the core token logic to be immutable and for the
 * hook logic to be upgradeable. This hook logic has been optimalized
 * to only incur one additional SLOAD per transfer if no hook is used.
 * The hook logic address may be locked to prevent future upgrades.
 *
 * If fees are collected, they are transfered to the custody of this
 * token contract and may be collected by the `feeCollector` role.
 *
 * Further, the `mint` and `burn` functions are only callable by the
 * `minter` and `burner` roles respectively. These roles are also
 * upgradeable and are designed to be locked once the system is
 * mature. If it is desired that the end user be able to mint and
 * burn tokens, then the `minter` and `burner` roles should have public
 * functions that allow the user to call them for these purposes.
 *
 */
contract GenericToken is
    Initializable,
    ERC20Upgradeable,
    // Immutable Address of Sudo for system
    AdminRole,
    // Extension storage and internal functions
    MinterRole,
    BurnerRole,
    FeeCollectorRole,
    ERC20HookTarget,
    DecimalOveride {
    /**
     * @dev This contract uses the OpenZeppelin-Upgradable definitions
     * but these contracts should never be deployed in an upgradeable manner.
     * Token contracts and other core infrastructure should be deployed in
     * a manner that protects users to the greatest extent possible.
     * Rather than upgrading the core handling logic of the system, the
     * system should be upgraded by changing out peripheral contracts while
     * leaving the core logic untouched. Further, by building these peripheral
     * contracts variables such that they may be locked to prevent future
     * manipulation, the system built in layers and locked down as the systems
     * tech stack matures.
     *
     * @param admin_ The address of the admin role contract.
     *
     */
    constructor(address admin_) AdminRole(admin_) {}

    function initialize(GenericTokenConfig calldata config_) public initializer {
        _setDecimals(config_.decimals);
        __ERC20_init(config_.name, config_.symbol);
        if (config_.burner != address(0)) _setBurner(config_.burner);
        if (config_.minter != address(0)) _setMinter(config_.minter);
        if (config_.hook != address(0)) _setERC20Hook(config_.hook);
    }

    function decimals() public view override returns (uint8) {
        return _getDecimals();
    }

    function changeMinter(address newMinter_) public onlyAdmin {
        _setMinter(newMinter_);
    }

    function lockMinter() public onlyAdmin {
        _lockMinter();
    }

    function changeBurner(address newBurner_) public onlyAdmin {
        _setBurner(newBurner_);
    }

    function lockBurner() public onlyAdmin {
        _lockBurner();
    }

    function changeERC20Hook(address newHook_) public onlyAdmin {
        _setERC20Hook(newHook_);
    }

    function lockERC20Hook() public onlyAdmin {
        _lockERC20Hook();
    }

    function changeFeeCollector(address newFeeCollector_) public onlyAdmin {
        _setFeeCollector(newFeeCollector_);
    }

    function lockFeeCollector() public onlyAdmin {
        _lockFeeCollector();
    }

    function mint(address to_, uint256 amount_) public onlyMinter {
        _mint(to_, amount_);
    }

    function burn(address from_, uint256 amount_) public onlyBurner {
        _burn(from_, amount_);
    }

    function collect(address to_) public onlyFeeCollector {
        uint256 balance = balanceOf(address(this));
        // do not invoke hooks in order to bypass fee
        super._transfer(address(this), to_, balance);
    }

    /**
     * @dev This function wraps the base _transfer function
     * This function invokes the custom before and after hook logic.
     *
     * This function short circuits to just perform a transfer
     * if the hook address is zero. if the hook address is not
     * zero, then the hook logic is called.
     *
     * The hook logic is as follows:
     *
     * The before hook is called first and is passed the
     * `from_`, `to_`, and `amount_` parameters. The before hook
     * returns a fee amount and a bool to indicate if after hook should
     * be called.
     *
     * If the `fee` is greater than zero, `fee` is transfered to
     * the this contracts control. The fee is taken from the caller's
     * balance to ensure that the amount tranfered to `to` matches `amount`.
     * If the `fee` is zero, then no fee is collected.
     *
     * Next, the caller's intended transfer is performed.
     *
     * Lastly, the after hook is called only if the after hook required
     * flag is returned as true by the before hook call. If the after
     * hook is required, it is passed the from, to, amount, and fee
     * parameters.
     *
     * @param amount_ How much to transfer.
     * @param from_ Who to transfer from.
     * @param to_ Who to transfer to.
     */
    function _transfer(
        uint256 amount_,
        address from_,
        address to_
    ) internal returns (bool) {
        address h = ERC20Hook();
        if (h == address(0)) {
            // SHORT CIRCUIT TRANSFER IF NO HOOK
            super._transfer(from_, to_, amount_);
            return true;
        } // ELSE PERFORM HOOKED TRANSFER
        IERC20HookLogic impl = IERC20HookLogic(h);
        uint256 fee;
        bool doAH;
        // GET FEE AND AFTER HOOK REQUIREMENT FROM BEFORE HOOK
        (fee, doAH) = impl.beforeTokenTransfer(from_, to_, amount_);
        if (fee != 0) {
            //  IF FEE IS NON-ZERO, COLLECT FEE
            super._transfer(from_, address(this), fee);
        } // TRANSFER AMOUNT REQUESTED BY USER
        super._transfer(from_, to_, amount_);
        if (doAH) {
            // IF AFTER HOOK IS REQUIRED, CALL IT
            impl.afterTokenTransfer(from_, to_, amount_, fee);
        }
        return true;
    }
}
