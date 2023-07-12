// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/bridge/error.sol";
import "contracts/bridge/events.sol";

import "contracts/common/access/roles/admin/admin.sol";
import "contracts/common/access/roles/burner/burner.sol";
import "contracts/common/access/roles/minter/minter.sol";
import "contracts/common/access/roles/fee/fee.sol";
import "contracts/common/access/roles/operator/operator.sol";

import "contracts/common/tooling/ERC20/gtmw.sol";
import "contracts/common/tooling/fees/fees.sol";
import "contracts/common/tooling/nonce/ncount.sol";
import "contracts/common/tooling/nonce/ntrack.sol";
import "contracts/common/tooling/pause/funcglobal.sol";
import "contracts/common/tooling/chainid/chainid.sol";


import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";


using EnumerableMap for EnumerableMap.UintToUintMap;


abstract contract ChainIDAware {

    EnumerableMap.UintToUintMap _approvedDestinations;
    uint256 _nativeChainID;

    function approveChainDest(uint256 dest_) internal returns (bool) {
        return _approvedDestinations.set(dest_, 1);
    }

    function revokeChainDest(uint256 dest_) internal returns (bool) {
        return _approvedDestinations.remove(dest_);
    }

    function approvedChains() public view returns (uint256[] memory) {
        return _approvedDestinations.keys();
    }

    function nativeChainID() public view returns (uint256) {
        return _nativeChainID;
    }

    function isApprovedChain(uint256 chain_) public view returns (bool) {
        return _approvedDestinations.contains(chain_);
    }

    function _setNativeChainID(uint256 nativeChainID_) internal {
        _nativeChainID = nativeChainID_;
    }

    function _isNativeChain() internal view returns (bool) {
        return _nativeChainID == block.chainid;
    }

    function _validateChain(uint256 chain_) internal view {
        if (!isApprovedChain(chain_)) {
            revert ChainNotApproved(chain_);
        }
    }
}


contract TokenBridgePool is BridgeEvents, AdminRole, OperatorRole, FeeCollectorRole, Pauseable, NonceTracker, NonceCounter, ChainIDAware {
    
    using EnumerableMap for EnumerableMap.UintToUintMap;
    using GenericTokenMiddleware for GenericTokenMiddleware.MiddlewareData;
    using Fees for Fees.FeesData;

    GenericTokenMiddleware.MiddlewareData private middleware;    
    Fees.FeesData public feesData;

    constructor(address admin_) AdminRole(admin_) {}

    function initialize(
        address operator_,
        address feeCollector_,
        address token_,
        uint8 fee_,
        uint128 nativeChainID_
    ) public onlyAdmin {
        _setNativeChainID(nativeChainID_);
        middleware._setToken(token_);
        feesData._setFee(fee_);
        // SETUP ROLES
        _setFeeCollector(feeCollector_);
        _setOperator(operator_);
    }


    //////////////////////////////////////////////////////////////////////////
    // CHAINID PERMIT/DENY FUNCTIONS /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

   
    function approveChain(uint256 dest_) public onlyAdmin {
        _approvedDestinations.set(dest_, 1);
    }

    function revokeChain(uint256 dest_) public onlyAdmin {
        _approvedDestinations.remove(dest_);
    }


    
    //////////////////////////////////////////////////////////////////////////
    // FEE FUNCTIONS /////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

    /**
    */
    function changeFee(uint8 fee_) public onlyAdmin {
        feesData._changeFee(fee_);
    }

    //////////////////////////////////////////////////////////////////////////
    // PAUSE FUNCTIONS ///////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

       /**
    * @dev Pauses a specific function by its function signature.
    * @param funcSig_ The function signature to be paused.
    */
   function pause(bytes4 funcSig_) public onlyAdmin {
       _pause(funcSig_);
   }
   
   /**
    * @dev Unpauses a specific function by its function signature.
    * @param funcSig_ The function signature to be unpaused.
    */
   function unpause(bytes4 funcSig_) public onlyAdmin {
       _unpause(funcSig_);
   }
   
   /**
    * @dev Pauses all functions in the contract.
    */
   function globalPause() public onlyAdmin {
       _globalPause();
   }
   
   /**
    * @dev Unpauses all functions in the contract.
    */
   function globalUnpause() public onlyAdmin {
       _globalUnpause();
   }

    //////////////////////////////////////////////////////////////////////////
    // DEPOSIT/WITHDRAW FUNCTIONS/////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////

function withdrawTokens(
    uint128 chain_,
    uint128 nonce_,
    address to_,
    uint256 amount_) public onlyOperator whenNotPaused {
    // NO FEES ON EXIT OF BRIDGE
    // MUST CHECK NON ZERO AMOUNT
    if (amount_ == 0) {
        revert ZeroWithdrawal();
    }
    // CHECK NONCE
    _consumeNonce(chain_, nonce_);
    // CHECK MODE OF OPERATION
    if (_isNativeChain()) {
        middleware._transfer(to_, amount_);
    } else {
        middleware._mintTo(to_, amount_);
    }
    // EMIT TRACKING EVENT FOR BRIDGE OPERATORS
    emit Withdrawal(
        address(middleware._tokenAddr()), // TOKEN ADDRESS
        to_, // DESTINATION ACCOUNT
        amount_, // DEPOSIT AMOUNT LESS FEES
        nonce_, // DEPOSIT NONCE
        nativeChainID() // TOKEN'S NATIVE CHAIN ID
    );
}

    //////////////////////////////////////////////////////////////////////////
    // FEE COLLECTION FUNCTION ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////


/**
 */
function collect(
    address to_
) public onlyFeeCollector whenNotPaused {
    uint256 amount = feesData._zeroAccruedFees();
    middleware._transfer(to_, amount);
}

    function deposit(uint256 chain_, address to_, uint256 amount_) public whenNotPaused returns (uint256 depAmt, uint256 feeAmt, uint256 depNum) {
        // CHECK IF DESTINATION CHAIN IS APPROVED
        if (!isApprovedChain(chain_)) {
            revert ChainNotApproved(chain_);
        }
        bool zeroFee; // SETUP LOCAL VAR OTHERS IN RET BLOCK
        // CALC FEES AND CHECK FOR VIOLATION OF MIN VALUES
        (depAmt, feeAmt, zeroFee) = feesData.calcFee(amount_);
        if (depAmt == 0) {
            // ZERO VALUE DEPOSIT NOT ALLOWED
            revert ZeroDeposit();
        }
        if ((feeAmt == 0) && (!zeroFee)) {
            // WITH FEE>0 REQ FEEAMT>0
            revert FeeFloorViolation();
        }
        // ADD FEES TO OUR LOCAL FEE ACCUMULATOR
        feesData._addAccruedFees(feeAmt);
        // INCREMENT NONCE
        depNum = _incrementNonce();
        // LOCAL STATE HAS BEEN UPDATED: EXTERNAL CALLS SAFE
        if (_isNativeChain()) {
            // NATIVE CHAIN OPERATIONS ARE `transferFrom`
            middleware._transferFrom(msg.sender, amount_);
        } else {
            // NON-NATIVE CHAIN OPERATIONS ARE `burnFrom`
            // NON-NATIVE ENV IMPLIES WE DEPLOYED ERC20
            middleware._burnFrom(msg.sender, amount_);
        }
        // EMIT TRACKING EVENT FOR BRIDGE OPERATORS
        emit Deposit(
            address(middleware._tokenAddr()), // TOKEN ADDRESS
            to_, // DESTINATION ACCOUNT
            depAmt, // DEPOSIT AMOUNT LESS FEES
            depNum, // DEPOSIT NONCE
            nativeChainID(), // TOKEN'S NATIVE CHAIN ID
            chain_ // DESTINATION CHAIN ID
        );
    }

}


/*
contract NativeBridgeFactory is GenericFactory, AdminRole {
    constructor() {
        _setAdmin(msg.sender);
    }

    function deploy(
        address token_,
        string symbol_
    ) public onlyAdmin returns (address addr) {
        addr = _deploy(symbol_);
        TokenBridgeNativeChain instance = TokenBridgeNativeChain(addr);
        instance.initialize(admin(), token_, symbol_);
    }

    function _code() internal pure returns (bytes memory) {
        return type(TokenBridgeNativeChain).creationCode;
    }
}

*/