// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenAirdrop {
    uint256 public claimableTime;
    uint256 public totalEthAmount;
    uint256 public percentTobuy;
    address public tokenAddress;
    address public owner;

    struct UserInfo {
        address walletAddress;
        uint256 ethPaidAmount;
        uint256 canClaimAmount;
        bool claimedState;
    }

    constructor() {
        owner = msg.sender;
        claimableTime = 1711231255;
        totalEthAmount = 30 ether;
        percentTobuy = 50;
    }

    mapping(address => UserInfo) public users;

    event TokenClaimed(address user);

    // Modifier to restrict access to the contract deployer
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only contract owner can call this function"
        );
        _;
    }

    // Function to set the token address, accessible only by the contract owner
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        require(tokenAddress == address(0), "Token address already set");
        tokenAddress = _tokenAddress;
    }

    // Function to set the claimable time, accessible only by the contract owner
    function setClaimableTIme(uint256 _claimableTime) public onlyOwner {
        claimableTime = _claimableTime;
    }

    // Function to set the percent to buy, accessible only by the contract owner
    function setPercentToBuy(uint256 _percentTobuy) public onlyOwner {
        percentTobuy = _percentTobuy;
    }

    function payEthToClaimTokens() public payable {
        require(msg.value > 0, "ETH amount must be greater than 0");

        UserInfo storage user = users[msg.sender];
        user.walletAddress = msg.sender;
        user.ethPaidAmount += msg.value;
        user.canClaimAmount += msg.value * 100; // You will get 100 tokens
        user.claimedState = false;
    }

    function claimTokens() public {
        UserInfo storage user = users[msg.sender];
        require(
            tokenAddress != address(0) && block.timestamp > claimableTime,
            "ClaimableTime is not yet."
        );
        require(user.ethPaidAmount > 0, "No ETH paid by the user.");
        require(user.claimedState == false, "Tokens already claimed.");
        require(tokenAddress != address(0), "Token address not set.");

        // Transfer tokens to the user
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenAmount = user.canClaimAmount; // For simplicity, transfer tokens based on ETH amount paid
        token.transfer(msg.sender, tokenAmount);

        user.claimedState = true;
        user.ethPaidAmount = 0;
        user.canClaimAmount = 0;
        emit TokenClaimed(msg.sender);
    }

    // Function to withdraw eth, accessible only by the contract owner
    function withdrawAllEth() public onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner can withdraw all ETH"
        );

        uint256 contractBalance = address(this).balance;

        require(contractBalance > 0, "No ETH balance to withdraw");

        payable(owner).transfer(contractBalance);
    }

    // Function to withdraw token, accessible only by the contract owner

    function withdrawAllTokens() public onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner can withdraw all tokens"
        );

        IERC20 token = IERC20(tokenAddress);
        uint256 contractBalance = token.balanceOf(address(this));

        require(contractBalance > 0, "No tokens to withdraw");

        token.transfer(owner, contractBalance);
    }

    function getStakedInfoByUser(
        address staker
    ) external view returns (UserInfo memory) {
        return users[staker];
    }

    function getClaimableTime() external view returns (uint256) {
        return claimableTime;
    }

    function getTokenAddr() external view returns (address) {
        return tokenAddress;
    }

    function isTokenClaimable() external view returns (bool) {
        return tokenAddress != address(0) && block.timestamp > claimableTime;
    }

    function isAvailableTobuy() external view returns (bool) {
        uint256 contractBalance = address(this).balance;
        return ((contractBalance * 100) / totalEthAmount) < percentTobuy;
    }
}
