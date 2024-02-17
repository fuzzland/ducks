// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./DuckGame.sol";
import "./interfaces/IBlast.sol";
import "./interfaces/IUniswapPair.sol";
import "./interfaces/IWETH.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract Duck is DuckGame, ERC20, Ownable {
    IBlast public blast = IBlast(0x4300000000000000000000000000000000000002);
    IUniswapPair public LP;
    IWETH public WETH;


    constructor() ERC20("Duck", "DUCK") Ownable(msg.sender) {
        blast.configureClaimableGas();
        blast.configureClaimableYield();
    }

    function setLP(address _lp) external onlyOwner {
        LP = IUniswapPair(_lp);
    }

    function setWETH(address _weth) external onlyOwner {
        WETH = IWETH(_weth);
    }

    function setPlayFee(uint256 _playFee) external onlyOwner {
        playFee = _playFee;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

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

    function transfer(address to, uint256 amount) public override returns (bool) {
        addRewardToLP();
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        addRewardToLP();
        return super.transferFrom(from, to, amount);
    }

    function claimProfit() external {
        UserInfo storage info = userInfo[msg.sender];
        require(info.initialized, "User is not initialized");
        uint256 profit = getProfitSinceTimestamp(msg.sender, info.lastProfitCheckout);
        info.lastProfitCheckout = block.timestamp;
        require(profit > 0, "No profit to claim");
        _mint(msg.sender, profit);
    }
    
    receive() external payable {}
}
