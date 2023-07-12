// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AdminRole
 * @author Hunter Prendergast
 * @notice AdminRole contract implements an immutable administrative role.
 * Due to the immutable nature of this role, it is imperative that the
 * address of the admin is set to a smart contract and not an EOA.
 *
 * This contract is intended to be used in a bastion host pattern, where
 * the admin role is assigned to the same value for every contract in a
 * deployment. This contract should have an admin role that is mutable.
 * The pattern is as follows for a multisig controller:
 *
 * READ DIAGRAM AS THIS SYMBOL DENOTING A CALL FROM A CONTRACT TO ANOTHER
 *  LET MUT MEAN MUTABLE
 *  LET  `A--|B|-->C` DENOTE A CALL FROM A TO C WHERE A HAS ROLE B ON C
 *  LET IMUT MEAN IMMUTABLE
 *  LET CONTRACT_X REFER REFER TO A CONTRACT WITHIN AN INFRASTRUCTURE
 *
 * EOA1\                                                                            /CONTRACT_0
 * EOA2 \--|MUT_OWNER|-->MultiSigSafe--|MUT_ADMIN|-->BASTION_HOST--|IMMUT_ADMIN|-->|    ...
 * EOA3 /                                                                           \CONTRACT_N
 * EOA4/
 *
 * The multisig safe is a contract that has many owners under a threshold. This allows gracefull handoff
 * and prevents single point failure at the top of the call chain for administrative operations.
 *
 * The BastionHost is a contract that has a mutable admin role so that the MultiSigSafe can be replaced
 * if necessary, but only by the MultiSigSafe itself. This allows transparent upgrades to the access control
 * infrastructure independent of the logic infrastructure.
 *
 * The BastionHost is the branch point in a one to many mapping. This flow forces all administrative access
 * to enter through a single point that immplements essentially no internal logic but allows for calls
 * to be transparently routed through it, and allows all contracts below it to reference this single address
 * as an immutable administrative controller.
 *
 * The reason we do not directly assign an immutable admin role to the MultiSigSafe, from the perspective
 * of the system's contracts, is that the complexity of the MultiSigSafe is much greater than the BastionHost.
 * This complexity may lead to bugs, breaking modifications of EVM operation, or other issues that can
 * not be forseen. Rather than lock ourselves into a single implementation of the MultiSigSafe, we instead
 * can use the BastionHost as the stable point with mutation capabilities only above. Further, we can layer
 * Access Control contracts above the bastion host to restrict the calls that can be performed by the
 * multisig safe. We can even have many multisig safes that have different roles/capabilities on an
 * intermediate access controller that is the admin of the bastion host.
 *
 * For example, we could have the subset of signers needed to perform an administrative operation on the
 * infrastructure be different than the subset of signers that would be needed to collect value from the
 * system. Lastly, since all contracts in the system will have the same immutable admin role assigned to
 * BastionHost, the BastionHost address being passed into all children down the call chain can still have
 * deterministic addresses.
 *
 *
 * The return flow of assets that the system asynchronously yields back into the control of the controlling
 * entity, should follow a similiar pattern as to the above. Namely, there should exist a single contract
 * that collects all Eth, ERC20s, ERC721s, etc etc etc. This contract should allow for limited upgrade via
 * allowing a delegatecall whitelist to be set by the admin. This delegatecall whitelist should be setup to
 * use a diamond type pattern to allow for multiple contracts to be used to handle asset callbacks/hooks or
 * other crazy requirements set forth by the fads of tomorrow.
 */
abstract contract AdminRole {
    error NotAdmin();
    address private immutable _admin;

    constructor(address admin_) {
        _admin = admin_;
    }

    modifier onlyAdmin() {
        if (msg.sender != _admin) {
            revert NotAdmin();
        }
        _;
    }

    function admin() public view returns (address) {
        return _admin;
    }
}
