// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ProfitInfo.sol";

contract DuckGame is ProfitInfo {
    uint256 public playFee = 0.01 ether;
    uint256 public timePerClaim = 1 days;
    uint256 public mintCooldown = 5; // 5 seconds
    uint256 public duckProfit = 1;

    mapping (address => UserInfo) public userInfo;

    enum ActionType {
        INIT,
        MINT,
        COMBINE
    }

    struct Action {
        ActionType actionType; // 0 - initialize, 1 - mint duck, 2 - combine ducks
        uint256 timestamp; // timestamp of the action
        uint256 extraInfo; // can be used for duck level
    }

    struct UserInfo {
        bool initialized; // is user initialized
        uint256 lastProfitCheckout; // timestamp
        uint256 lastCheckpoint; // timestamp
        uint256 totalProfit; // total profit
        uint256 profitPerSecond; // profit per second
        mapping (uint32 => uint256) ducks; // level => count
    }

    event InitUser(address indexed user, uint256 timestamp);
    event MintDuck(address indexed user, uint256 timestamp);
    event CombineDucks(address indexed user, uint256 timestamp, uint32 level);

    function checkpoint(Action[] calldata actions) external payable {
        UserInfo storage info = userInfo[msg.sender];
        uint256 timestamp = block.timestamp;
        uint256 lastCheckpoint = info.lastCheckpoint;
        uint256 _duckProfit = duckProfit;

        for (uint256 i = 0; i < actions.length; i++) {
            Action memory action = actions[i];
            if (action.actionType == ActionType.INIT) {  // initialize account
                require(msg.value >= playFee, "Not enough fee");
                require(!info.initialized, "User is already initialized");
                info.initialized = true;
                initializeNode(msg.sender);
                emit InitUser(msg.sender, timestamp);
            }
            if (action.actionType == ActionType.MINT) {  // mint duck
                require(info.initialized, "User is not initialized");
                require(action.timestamp > lastCheckpoint + mintCooldown, "Can only mint duck after cooldown");
                require(action.timestamp < timestamp, "Invalid timestamp");

                lastCheckpoint = lastCheckpoint + mintCooldown;
                info.ducks[0] += 1;
                info.profitPerSecond += _duckProfit;

                addNode(msg.sender, action.timestamp, info.profitPerSecond);
                
                emit MintDuck(msg.sender, action.timestamp);
            }
            if (action.actionType == ActionType.COMBINE) { // combine ducks
                require(info.initialized, "User is not initialized");
                uint32 level = uint32(action.extraInfo);
                require(level > 0, "Invalid duck level");
                require(info.ducks[level - 1] >= 2, "Not enough ducks to combine");
                require(action.timestamp < timestamp, "Invalid timestamp");
                require(action.timestamp > lastCheckpoint, "Can only combine ducks after last checkpoint");

                info.ducks[level - 1] -= 2;
                info.ducks[level] += 1;
                info.profitPerSecond += _duckProfit * level * 2;

                addNode(msg.sender, action.timestamp, info.profitPerSecond);

                emit CombineDucks(msg.sender, action.timestamp, level);
            }
        }
        info.lastCheckpoint = lastCheckpoint;
    }
}