
    struct MultiCallArgs {
        address target;
        uint256 value;
        bytes data;
    }

    /**
     * @notice _callAny allows EOA to call function impersonating the factory address
     * @param target_: the address of the contract to be called
     * @param value_: value in WEIs to send together the call
     * @param cdata_: Hex encoded data with function signature + arguments of the target function to be called
     */
    function _callAny(
        address target_,
        uint256 value_,
        bytes memory cdata_
    ) internal returns (bytes memory) {
        return target_.functionCallWithValue(cdata_, value_);
    }

    /**
     * @notice callAny allows EOA to call function impersonating the factory address
     * @param target_: the address of the contract to be called
     * @param value_: value in WEIs to send together the call
     * @param cdata_: Hex encoded state with function signature + arguments of the target function to be called
     * @return the return of the calls as a byte array
     */
    function callAny(
        address target_,
        uint256 value_,
        bytes calldata cdata_
    ) public payable onlyOwner returns (bytes memory) {
        bytes memory cdata = cdata_;
        return _callAny(target_, value_, cdata);
    }

    /**
     * @notice multiCall allows owner to make multiple function calls within a single transaction
     * impersonating the factory
     * @param cdata_: array of hex encoded state with the function calls (function signature + arguments)
     * @return an array with all the returns of the calls
     */
    function multiCall(
        MultiCallArgs[] calldata cdata_
    ) public onlyOwner returns (bytes[] memory) {
        return _multiCall(cdata_);
    }
}
