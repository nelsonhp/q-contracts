// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "contracts/common/access/roles/burner/burner.sol";

   /**
    * @title MockBurner
    * @dev A contract that mocks the BurnerRole contract.
    */
   contract MockBurner is BurnerRole {
       /**
        * @dev Constructor function
        * @param a_ The address to set as the burner
        */
       constructor(address a_) {
           _setBurner(a_);
       }
   
       /**
        * @dev Function to change the burner address
        * @param newBurner_ The new address to set as the burner
        */
       function changeBurner(address newBurner_) public {
           _setBurner(newBurner_);
       }
   
       /**
        * @dev Function to lock the burner address
        */
       function lockBurner() public  {
           _lockBurner();
       }

    function protected() public view onlyBurner returns (bool) {
        return true;
    }
}
