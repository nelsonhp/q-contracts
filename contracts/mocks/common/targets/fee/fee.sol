// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/access/roles/fee/fee.sol";

contract MockFeeCollectorTarget is FeeCollectorRole {
    constructor(address a_) {
        _setFeeCollector(a_);
    }

    function changeFeeCollector(
        address newFeeCollectorTarget_
    ) public  {
        _setFeeCollector(newFeeCollectorTarget_);
    }

    function lockFeeCollector() public {
        _lockFeeCollector();
    }
}
