contract DelegateProxy {
  /**
   * @dev Performs a delegatecall and returns whatever the delegatecall returned (entire context execution will return!)
   * @param _dst Destination address to perform the delegatecall
   * @param _calldata Calldata for the delegatecall
   */
  function delegatedFwd(address _dst, bytes memory _calldata) internal {
    require(isContract(_dst));
    assembly {
      let result := delegatecall(sub(gas(), 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
      let size := returndatasize()

      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)

      // revert instead of invalid() bc if the underlying call failed with invalid() it already wasted gas.
      // if the call returned error data, forward it
      switch result case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }

  function isContract(address _target) view internal returns (bool) {
    uint256 size;
    assembly { size := extcodesize(_target) }
    return size > 0;
  }
}

contract Proxy is DelegateProxy {
  address currentContract;

  

  function upgrade(address newContract) public {
    currentContract = newContract;
  }

  fallback () payable external {
    require(currentContract != address(0)); // if app code hasn't been set yet, don't call
    delegatedFwd(currentContract, msg.data);
  }
}