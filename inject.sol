// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GeoExplorationGame {

    struct Location {
        uint256 id;
        string name;
        string description;
        uint256 reward;
        bool active;
    }

    address public owner;
    uint256 public totalLocations;
    uint256 public totalTokens;

    mapping(uint256 => Location) public locations;
    mapping(address => uint256) public userBalances;

    event LocationCreated(uint256 locationId, string name, uint256 reward);
    event LocationExplored(address indexed user, uint256 locationId, uint256 reward);
    event TokensWithdrawn(address indexed user, uint256 amount);
    event TokensDeposited(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier locationExists(uint256 locationId) {
        require(locationId < totalLocations, "Location does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalLocations = 0;
        totalTokens = 1000000; // Initial total tokens available for rewards
    }

    // Function to create a new location for exploration
    function createLocation(string memory _name, string memory _description, uint256 _reward) public onlyOwner {
        require(_reward > 0 && _reward <= totalTokens, "Invalid reward amount");
        locations[totalLocations] = Location(totalLocations, _name, _description, _reward, true);
        totalLocations++;
        totalTokens -= _reward; // Decrease the remaining total tokens
        emit LocationCreated(totalLocations - 1, _name, _reward);
    }

    // Function for a user to explore a location and earn a reward
    function exploreLocation(uint256 locationId) public locationExists(locationId) {
        Location storage location = locations[locationId];
        require(location.active, "This location is no longer active");

        // Award reward to the user
        userBalances[msg.sender] += location.reward;
        emit LocationExplored(msg.sender, locationId, location.reward);
    }

    // Function for users to withdraw their earned tokens
    function withdrawTokens(uint256 amount) public {
        require(userBalances[msg.sender] >= amount, "Insufficient balance");
        userBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    // Owner function to deposit tokens into the contract
    function depositTokens() public payable onlyOwner {
        totalTokens += msg.value;
        emit TokensDeposited(msg.sender, msg.value);
    }

    // Function to retrieve the balance of a user
    function getUserBalance(address user) public view returns (uint256) {
        return userBalances[user];
    }

    // Function to retrieve information about a location
    function getLocation(uint256 locationId) public view locationExists(locationId) returns (string memory, string memory, uint256, bool) {
        Location storage location = locations[locationId];
        return (location.name, location.description, location.reward, location.active);
    }
}
