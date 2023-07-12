// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/constants/unitone.sol";

library Fees {
    error FeeTooHigh();

    struct FeesData {
        uint256 _fee;
        uint256 _accruedFees;
    }


    function calcFee(
        FeesData storage self,
        uint256 amount_
    ) public view returns (uint256 ao, uint256 fo, bool zf) {
        uint256 f = self._fee;
        zf = f == 0;
        ao = ((UNIT_ONE - f) * amount_) / UNIT_ONE;
        fo = amount_ - ao;
    }

    function fee(FeesData storage self) internal view returns (uint256) {
        return self._fee;
    }

    function accruedFees(FeesData storage self) public view returns (uint256) {
        return self._accruedFees;
    }

    function _changeFee(FeesData storage self, uint256 fee_) internal {
        self._fee = fee_;
    }

    function _addAccruedFees(FeesData storage self, uint256 amount_) internal returns (uint256) {
        uint256 balance = self._accruedFees;
        balance += amount_;
        self._accruedFees = balance;
        return balance;
    }

    function _zeroAccruedFees(FeesData storage self) internal returns (uint256) {
        uint256 balance = self._accruedFees;
        self._accruedFees = 0;
        return balance;
    }

    function _setFee(FeesData storage self, uint256 fee_) internal {
        if (UNIT_ONE >= fee_) {
            revert FeeTooHigh();
        }
        self._fee = fee_;
    }

}