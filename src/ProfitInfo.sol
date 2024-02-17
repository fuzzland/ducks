// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/* 
    ProfitInfo is a contract that stores the profit information for the users.
    It is used to calculate the profit of the users and to distribute the profits.
*/
contract ProfitInfo {
    /// @dev Node struct, used to store the profit per second for a specific time
    struct Node {
        uint256 timestamp;
        uint256 profitPerSecond;
    }

    /// @dev First node for the user
    mapping(address => uint256) public firstNode;

    /// @dev Nodes for the user
    mapping(address => Node[]) public nodes;

    /// @dev Initialize the user
    /// @param user The user address
    function initializeNode(address user) internal {
        nodes[user][0] = Node(block.timestamp, 0);
        firstNode[user] = 0;
    }

    /// @dev Add a new node for the user
    /// @param user The user address
    /// @param timestamp The timestamp of the node
    /// @param profitPerSecond The profit per second of the node
    function addNode(
        address user,
        uint256 timestamp,
        uint256 profitPerSecond
    ) internal {
        uint256 id = nodes[user].length;
        nodes[user][id] = Node(timestamp, profitPerSecond);
    }

    /// @dev Get the profit of the user, since the timestamp
    /// @param user The user address
    /// @param timestamp The timestamp to calculate the profit since
    function getProfitSinceTimestamp(
        address user,
        uint256 timestamp
    ) public view returns (uint256) {
        uint256 profit = 0;
        uint256 lastTimestamp = timestamp;
        uint256 lastNode = firstNode[user];

        for (uint256 i = firstNode[user]; i < nodes[user].length; i++) {
            // If the node is before the timestamp, skip it
            if (nodes[user][i].timestamp < timestamp) {
                lastNode = i;
                continue;
            }
            // Calculate the profit for the node
            uint256 timeDiff = nodes[user][i].timestamp - lastTimestamp;
            uint256 nodeProfit = timeDiff *
                nodes[user][lastNode].profitPerSecond;
            profit += nodeProfit;
        }
        return profit;
    }
}
