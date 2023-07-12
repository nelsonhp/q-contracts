// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/ERC20Hook/hook.sol";
import "contracts/ERC20Hook/ihook.sol";

abstract contract  MockERC20Hook is ERC20HookLogic {
    address constant _token = address(0x1);

    uint256 constant _beforeMintFee = 1;
    uint256 constant _beforeBurnFee = 2;
    uint256 constant _beforeTransferFee = 3;

    address _beforeMintTo;
    uint256 _beforeMintAmount;

    address _beforeBurnFrom;
    uint256 _beforeBurnAmount;

    address _beforeTransferFrom;
    address _beforeTransferTo;
    uint256 _beforeTransferAmount;

    constructor(
        address admin_,
        address token_
    ) ERC20HookLogic(admin_, token_) {}

    function _beforeMint(
        address to_,
        uint256 amount_
    ) internal virtual override returns (uint256 fee) {
        _beforeMintTo = to_;
        _beforeMintAmount = amount_;
        return _beforeBurnFee;
    }

    function _beforeBurn(
        address from_,
        uint256 amount_
    ) internal virtual override returns (uint256 fee) {
        _beforeBurnFrom = from_;
        _beforeBurnAmount = amount_;
        return 2;
    }

    function _beforeTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal virtual override returns (uint256 fee) {
        _beforeTransferFrom = from_;
        _beforeTransferTo = to_;
        _beforeTransferAmount = amount_;
        return _beforeTransferFee;
    }

    function _afterMint(
        address to_,
        uint256 amount_,
        uint256 fee_
    ) internal virtual override {
        require(_beforeMintTo == to_, "Invalid to");
        require(_beforeMintAmount == amount_, "Invalid amount");
        require(_beforeMintFee == fee_, "Invalid fee");
        return;
    }

    function _afterBurn(
        address from_,
        uint256 amount_,
        uint256 fee_
    ) internal virtual override {
        require(_beforeBurnFrom == from_, "Invalid from");
        require(_beforeBurnAmount == amount_, "Invalid amount");
        require(_beforeBurnFee == fee_, "Invalid fee");
        return;
    }

    function _afterTransfer(
        address from_,
        address to_,
        uint256 amount_,
        uint256 fee_
    ) internal virtual override {
        require(_beforeTransferFrom == from_, "Invalid from");
        require(_beforeTransferTo == to_, "Invalid to");
        require(_beforeTransferAmount == amount_, "Invalid amount");
        require(_beforeTransferFee == fee_, "Invalid fee");
        return;
    }
}
