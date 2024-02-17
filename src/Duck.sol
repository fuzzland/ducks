// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./DuckGame.sol";
import "./interfaces/IBlast.sol";
import "./interfaces/IUniswapPair.sol";
import "./interfaces/IWETH.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/* 
    Duck is the main token of the game. It is an ERC20 token with some additional functionality.
    It is used to play the game, and to claim rewards from the yield farming and gas fees.
    It also has a claimProfit function that allows users to claim their share of the profits from the game.
*/
contract Duck is DuckGame, ERC20, Ownable {
    /// @dev BLAST contract
    IBlast public blast = IBlast(0x4300000000000000000000000000000000000002);

    /// @dev LP of the token
    IUniswapPair public LP;

    /// @dev WETH token address
    IWETH public WETH;

    constructor() ERC20("Duck", "DUCK") Ownable(msg.sender) {
        blast.configureClaimableGas();
        blast.configureClaimableYield();
    }

    /// @dev Set the LP address for the token
    function setLP(address _lp) external onlyOwner {
        LP = IUniswapPair(_lp);
    }

    /// @dev Set the WEth address
    function setWETH(address _weth) external onlyOwner {
        WETH = IWETH(_weth);
    }

    /// @dev Set the entry fee for the game
    function setPlayFee(uint256 _playFee) external onlyOwner {
        playFee = _playFee;
    }

    /// @dev Owner can mint new tokens
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// @dev Add the rewards from the yield farming and gas fees to the LP
    function addRewardToLP() internal {
        uint256 balanceBefore = address(this).balance;
        blast.claimAllGas(address(this), address(this));
        blast.claimAllYield(address(this), address(this));
        uint256 balanceAfter = address(this).balance;
        uint256 amount = balanceAfter - balanceBefore;
        if (amount > 0) {
            WETH.deposit{value: amount}();
            WETH.transfer(address(LP), amount);
            LP.sync();
        }
    }

    /// @dev Transfer the tokens and add the rewards to the LP
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        addRewardToLP();
        return super.transfer(to, amount);
    }

    /// @dev Transfer the tokens and add the rewards to the LP
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        addRewardToLP();
        return super.transferFrom(from, to, amount);
    }

    /// @dev Claim the profits from the game
    function claimProfit() external {
        UserInfo storage info = userInfo[msg.sender];
        require(info.initialized, "User is not initialized");
        uint256 profit = getProfitSinceTimestamp(
            msg.sender,
            info.lastProfitCheckout
        );
        info.lastProfitCheckout = block.timestamp;
        require(profit > 0, "No profit to claim");
        _mint(msg.sender, profit);
    }

    /// @dev Fallback function to receive ETH from players
    receive() external payable {}
}
