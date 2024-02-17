// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract ProfitInfo {
    struct Node {
        uint256 timestamp;
        uint256 profitPerSecond;
    }

    mapping (address => uint256) public firstNode;
    mapping (address => Node[]) public nodes;

    function initializeNode(address user) internal {
        nodes[user][0] = Node(block.timestamp, 0);
        firstNode[user] = 0;
    }

    function addNode(address user, uint256 timestamp, uint256 profitPerSecond) internal {
        uint256 id = nodes[user].length;
        nodes[user][id] = Node(timestamp, profitPerSecond);
    }

    function getProfitSinceTimestamp(address user, uint256 timestamp) public view returns (uint256) {
        uint256 profit = 0;
        uint256 lastTimestamp = timestamp;
        uint256 lastNode = firstNode[user];
        
        for (uint256 i = firstNode[user]; i < nodes[user].length; i++) {
            if (nodes[user][i].timestamp < timestamp) {
                lastNode = i;
                continue;
            }
            uint256 timeDiff = nodes[user][i].timestamp - lastTimestamp;
            uint256 nodeProfit = timeDiff * nodes[user][lastNode].profitPerSecond;
            profit += nodeProfit;
        }
        return profit;
    }
}