// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "contracts/ERC20/BASEIMPL/config.sol";


interface IGenericToken is IERC20Upgradeable {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
}

interface IGenericTokenAdmin {
    function initialize(GenericTokenConfig memory config_) external;
    function admin() external view returns (address);

    function minter() external view returns (address);

    function minterIsLocked() external view returns (bool);

    function lockMinter() external;

    function changeMinter(address newMinter_) external;

    function burner() external view returns (address);

    function burnerIsLocked() external view returns (bool);

    function lockBurner() external;

    function changeBurner(address newBurner_) external;

    function hook() external view returns (address);

    function hookIsLocked() external view returns (bool);

    function lockHook() external;

    function changeHook(address newHook_) external;

    function feeCollector() external view returns (address);

    function lockFeeCollector() external;

    function changeFeeCollector(address newFeeCollector_) external;

    function collect(address to_) external;
}
