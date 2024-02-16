// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

enum GasMode {
    VOID,
    CLAIMABLE 
}

interface IBlast {
    function configureClaimableGas() external;
    function claimAllGas(address contractAddress, address recipientOfGas) external returns (uint256);
    function claimGasAtMinClaimRate(address contractAddress, address recipientOfGas, uint256 minClaimRateBips) external returns (uint256);
    function readGasParams(address contractAddress) external view returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode);
}