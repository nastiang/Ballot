// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
 //import "@openzeppelin/contracts/access/Ownable.sol";

 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


contract Ballot is Ownable{
   
    struct Voter {
        mapping(uint => bool) isVoted;
        mapping(uint => uint) choice;
    }

    mapping(address => Voter) voters;

    struct Vote{
        string name;
        uint index;
        uint256 lastRun;
        bool isStarted;
        uint allProposalCount;
        uint proposalsCount;
    }

    Vote[] public votes;

    struct Proposal {
        string name;   
        uint voteCount; 
        address delegate;
    }


    mapping(uint => mapping (uint => Proposal)) proposals;

    uint256 public cost = 0.01 ether;
    bool isStarted = false;
    uint votesCount;

   function getVotes() public view returns (string[] memory,uint[] memory){
      string[]  memory name = new string[](votes.length);
      uint[]    memory index = new uint[](votes.length);
      for (uint i = 0; i < votes.length; i++) {
          Vote storage v = votes[i];
          name[i] = v.name;
          index[i] = v.index;
      }

      return (name,index);

  }

    function setVote(string memory _voteName) external onlyOwner {
        votes.push(
            Vote({
                name: _voteName,
                index: votes.length,
                lastRun: block.timestamp,
                isStarted: false,
                allProposalCount: 0,
                proposalsCount: 0
            })
        );
        votesCount ++;
    }

    function getProposals(uint voteIndex) public view returns (string[] memory,uint[] memory, address[] memory){
      string[] memory name = new string[](votes[voteIndex].proposalsCount);
      uint[] memory voteCount = new uint[](votes[voteIndex].proposalsCount);
      address[] memory delegate = new address[](votes[voteIndex].proposalsCount);
      for (uint i = 0; i < votes[voteIndex].proposalsCount; i++) {
          Proposal storage proposal = proposals[voteIndex][i];
          name[i] = proposal.name;
          voteCount[i] = proposal.voteCount;
          delegate[i] = proposal.delegate;
      }

      return (name,voteCount,delegate);

  }

    function setProposal(uint voteIndex, string memory proposalName, address _delegate) external onlyOwner {
        //ideally you need to check for duplicates
    proposals[voteIndex][votes[voteIndex].proposalsCount] = 
                Proposal({
                name: proposalName,
                voteCount: 0,
                delegate: _delegate
            });
            votes[voteIndex].proposalsCount++;
    }

    function startVoting(uint voteIndex) external onlyOwner {
        votes[voteIndex].isStarted = true;
        votes[voteIndex].lastRun = block.timestamp;

    }
    
    function vote(uint _voteIndex, uint _proposal) public payable{
        require(votes[_voteIndex].isStarted,'Voting has not started yet');
        require(msg.value >= cost);
        Voter storage sender = voters[msg.sender];
        require(!sender.isVoted[_voteIndex], "Already voted.");
        sender.choice[_voteIndex] = _proposal;
        sender.isVoted[_voteIndex] = true;
        proposals[_voteIndex][_proposal].voteCount ++;
        votes[_voteIndex].allProposalCount ++;

        }
          
    function winningProposal(uint _voteIndex) public view returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < votes[_voteIndex].proposalsCount; p++) {
           uint proposalCount = proposals[_voteIndex][p].voteCount;
            if (proposalCount > winningVoteCount) {
                winningVoteCount = proposalCount;
                winningProposal_ = p;
            }
        }
    }
  
    function winnerName(uint _voteIndex) public view
            returns (string memory winnerName_)
    {
        winnerName_ = proposals[_voteIndex][winningProposal(_voteIndex)].name;
    }

    function completeTheVote(uint voteIndex) public {
        require(block.timestamp - votes[voteIndex].lastRun > 3 days, 'Voting continues');
        votes[voteIndex].isStarted = false;
         address payable addr = payable(proposals[voteIndex][winningProposal(voteIndex)].delegate);
         uint256 percentOfFee = div(9,10);
         uint256 reward = 
         mul( 
             mul(votes[voteIndex].allProposalCount, cost)
             ,percentOfFee
            );
             addr.transfer(reward); 
    }

 

    function withdrawAll() external onlyOwner{
    //   for (uint p = 0; p < votes.length; p++) {         we may or may not:)))
    //      require(!votes[p].isStarted, 'Not all votes are over');
    //   }
  
    payable(msg.sender).transfer(address(this).balance);

    }

    function selfDestruct(address _address) external onlyOwner { 
      selfdestruct(payable(_address)); 
}

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}
