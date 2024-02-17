// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ProfitInfo.sol";

/* 
    DuckGame is the main game contract. 
*/
contract DuckGame is ProfitInfo {
    /// @dev Entry fee for the game
    uint256 public playFee = 0.01 ether;

    /// @dev Cooldown time between minting a new duck
    uint256 public mintCooldown = 5; // 5 seconds

    /// @dev Profit per second for one smallest duck
    uint256 public duckProfit = 1;

    /// @dev User info
    mapping(address => UserInfo) public userInfo;

    enum ActionType {
        /// @dev Initialize user
        INIT,
        /// @dev Mint a duck
        MINT,
        /// @dev Combine ducks
        COMBINE
    }

    /// @dev Action struct, used to store the actions of the user
    struct Action {
        /// @dev Type of the action: 0 - initialize, 1 - mint duck, 2 - combine ducks
        ActionType actionType;
        /// @dev Timestamp of the action
        uint256 timestamp;
        /// @dev Extra info, can be used for duck level
        uint256 extraInfo;
    }

    /// @dev User info struct
    struct UserInfo {
        /// @dev Is user initialized
        bool initialized;
        /// @dev Timestamp of the last profit checkout
        uint256 lastProfitCheckout;
        /// @dev Timestamp of the last checkpoint
        uint256 lastCheckpoint;
        /// @dev Total profit of the user
        uint256 profitPerSecond;
        /// @dev Ducks of the user, mapping from level to count
        mapping(uint32 => uint256) ducks;
    }

    /// @dev Initialize the user
    event InitUser(address indexed user, uint256 timestamp);
    /// @dev Mint duck
    event MintDuck(address indexed user, uint256 timestamp);
    /// @dev Combine ducks
    event CombineDucks(address indexed user, uint256 timestamp, uint32 level);

    /// @dev Checkpoint function, used to update the user info, mint ducks, and combine ducks
    /// @param actions Array of actions performed by the user (INIT, MINT, COMBINE)
    /// @dev The function is payable, as the user needs to pay the entry fee
    function checkpoint(Action[] calldata actions) external payable {
        UserInfo storage info = userInfo[msg.sender];
        uint256 timestamp = block.timestamp;
        uint256 lastCheckpoint = info.lastCheckpoint;
        uint256 _duckProfit = duckProfit;

        for (uint256 i = 0; i < actions.length; i++) {
            Action memory action = actions[i];
            if (action.actionType == ActionType.INIT) {
                // initialize account
                require(msg.value >= playFee, "Not enough fee");
                require(!info.initialized, "User is already initialized");
                info.initialized = true;
                initializeNode(msg.sender);
                emit InitUser(msg.sender, timestamp);
            }
            if (action.actionType == ActionType.MINT) {
                // mint duck
                require(info.initialized, "User is not initialized");
                require(
                    action.timestamp > lastCheckpoint + mintCooldown,
                    "Can only mint duck after cooldown"
                );
                require(action.timestamp < timestamp, "Invalid timestamp");

                lastCheckpoint = lastCheckpoint + mintCooldown;
                info.ducks[0] += 1;
                info.profitPerSecond += _duckProfit;

                addNode(msg.sender, action.timestamp, info.profitPerSecond);

                emit MintDuck(msg.sender, action.timestamp);
            }
            if (action.actionType == ActionType.COMBINE) {
                // combine ducks
                require(info.initialized, "User is not initialized");
                uint32 level = uint32(action.extraInfo);
                require(level > 0, "Invalid duck level");
                require(
                    info.ducks[level - 1] >= 2,
                    "Not enough ducks to combine"
                );
                require(action.timestamp < timestamp, "Invalid timestamp");
                require(
                    action.timestamp > lastCheckpoint,
                    "Can only combine ducks after last checkpoint"
                );

                info.ducks[level - 1] -= 2;
                info.ducks[level] += 1;
                info.profitPerSecond += _duckProfit * level * 2;

                addNode(msg.sender, action.timestamp, info.profitPerSecond);

                emit CombineDucks(msg.sender, action.timestamp, level);
            }
        }
        // update last checkpoint
        info.lastCheckpoint = lastCheckpoint;
    }
}
