// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    address public owner;
    uint256 public votingDeadline;
    bool public votingStarted;
    bool public votingEnded;
    
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    Candidate[] public candidates;
    mapping(address => bool) public hasVoted;

    event Voted(address indexed voter, uint256 candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    modifier onlyBeforeDeadline() {
        require(block.timestamp < votingDeadline, "Voting period has ended.");
        _;
    }

    modifier onlyAfterDeadline() {
        require(block.timestamp >= votingDeadline, "Voting period is still ongoing.");
        _;
    }

    modifier votingOpen() {
        require(votingStarted && !votingEnded, "Voting is not active.");
        _;
    }

    constructor(uint256 _votingDurationInMinutes) {
        owner = msg.sender;
        votingDeadline = block.timestamp + _votingDurationInMinutes * 1 minutes;
        votingStarted = false;
        votingEnded = false;
    }

    function addCandidate(string memory _candidateName) public onlyOwner onlyBeforeDeadline {
        require(!votingStarted, "Cannot add candidates after voting has started.");
        candidates.push(Candidate(_candidateName, 0));
    }

    function startVoting() public onlyOwner onlyBeforeDeadline {
        require(candidates.length > 0, "No candidates to vote for.");
        votingStarted = true;
    }

    function endVoting() public onlyOwner onlyAfterDeadline {
        require(!votingEnded, "Voting has already ended.");
        votingEnded = true;
    }

    function vote(uint256 _candidateId) public votingOpen {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(_candidateId < candidates.length, "Invalid candidate ID.");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit Voted(msg.sender, _candidateId);
    }

    function getTotalCandidates() public view returns (uint256) {
        return candidates.length;
    }

    function getVotes(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId < candidates.length, "Invalid candidate ID.");
        return candidates[_candidateId].voteCount;
    }

    function getWinningCandidate() public view onlyAfterDeadline returns (string memory winner) {
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = candidates[i].name;
            }
        }
    }

    function getVotingStatus() public view returns (bool started, bool ended, uint256 timeRemaining) {
        started = votingStarted;
        ended = votingEnded;
        if (block.timestamp < votingDeadline) {
            timeRemaining = votingDeadline - block.timestamp;
        } else {
            timeRemaining = 0;
        }
    }
}
