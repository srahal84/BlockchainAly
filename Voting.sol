// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/access/Ownable.sol";

contract Voting is Ownable {
    
    uint private winningProposalId;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;
    WorkflowStatus public workflowStatus = WorkflowStatus.RegisteringVoters;
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }
    
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    
    event VoterRegistered(address voterAddress);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted (address voter, uint proposalId);
    event VotesTallied();
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    
    modifier onlyDuringVotersRegistration() {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "function called only during voters registration");
        _;
    }
    
    modifier onlyDuringProposalsRegistration() {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "function called only during proposal registration");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "voter not registered");
        _;
    }
    
    modifier onlyDuringVotingSession() {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "function called only during the voting session");
        _;
    }
    
    function registerVoter(address _address) public onlyOwner onlyDuringVotersRegistration {
        require(!voters[_address].isRegistered, "voter already registered");
        
        voters[_address].isRegistered = true;
        voters[_address].hasVoted = false;
        voters[_address].votedProposalId = 0;
        
        emit VoterRegistered(_address);
    }
    
    function startProposalRegistration() public onlyOwner onlyDuringVotersRegistration {
        changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationStarted);
        emit ProposalsRegistrationStarted();
    }
    
    function endProposalRegistration() public onlyOwner onlyDuringProposalsRegistration {
        changeWorkflowStatus(WorkflowStatus.ProposalsRegistrationEnded);
        emit ProposalsRegistrationEnded();
    }
    
    function registerProposal(string memory _propDescription) public onlyDuringProposalsRegistration onlyRegisteredVoter {
        
        proposals.push(Proposal({
            description: _propDescription,
            voteCount: 0
        }));
        
        emit ProposalRegistered(proposals.length);
    }
    
    function startVotingSession() public onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, "function called only after proposal registration");
        changeWorkflowStatus(WorkflowStatus.VotingSessionStarted);
        emit VotingSessionStarted();
    }
    
    function endVotingSession() public onlyOwner onlyDuringVotingSession {
        changeWorkflowStatus(WorkflowStatus.VotingSessionEnded);
        emit VotingSessionEnded();
    }
    
    function vote(uint _proposalId) public onlyRegisteredVoter onlyDuringVotingSession {
        require(!voters[msg.sender].hasVoted, "Caller already voted");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        
        proposals[_proposalId].voteCount += 1;
        
        emit Voted(msg.sender, _proposalId);
    }
    
    function tallyVotes() onlyOwner public {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "this function can be called only after the voting session has ended");
        
        uint winningVoteCount = 0;
        uint winningProposal = 0;
        
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposal = i;
            }
        }
        
        winningProposalId = winningProposal;
        changeWorkflowStatus(WorkflowStatus.VotesTallied);
        
        emit VotesTallied();
    }
    
    function winningProposal() public view returns (string memory, uint)
    {
        require(workflowStatus == WorkflowStatus.VotesTallied, "function called only after votes have been tallied");
        return (proposals[winningProposalId].description, proposals[winningProposalId].voteCount);
    }
    
    function changeWorkflowStatus(WorkflowStatus _workflowStatus) internal {
        emit WorkflowStatusChange(workflowStatus, _workflowStatus);
        workflowStatus = _workflowStatus;
    }
    
}