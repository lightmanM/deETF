pragma solidity ^0.8.13;

contract DummyVerifier {
    function verify(
        uint256[] calldata proof,
        uint256[] calldata verify_instance,
        uint256[] calldata aux,
        uint256[][] calldata target_instance
    ) external view {
        // Always return true
        require(true, "Verification failed");
    }
}