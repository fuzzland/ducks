contract TestBlast {
    function configureClaimableYield() external {

    }

    function configureClaimableGas() external {

    }

    function claimAllYield(
        address contractAddress,
        address recipientOfYield
    ) external returns (uint256) {
        return 0;
    }

    // claim gas
    function claimAllGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256) {
        return 0;
    }

}

contract TestBlastWithGasYield {
    function configureClaimableYield() external {

    }

    function configureClaimableGas() external {

    }

    function claimAllYield(
        address contractAddress,
        address recipientOfYield
    ) external returns (uint256) {
        payable(msg.sender).transfer(100);
        return 0;
    }

    // claim gas
    function claimAllGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256) {
        payable(msg.sender).transfer(100);
        return 0;
    }

}