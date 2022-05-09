
const { ethers } = require("hardhat")

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')())
    .should();
    
const { expect } = require("chai");
const { voidType } = require("io-ts");

describe("Ballot contract", function () {
  
  let Ballot;
  let ballot;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  
  beforeEach(async function () {
    Ballot = await ethers.getContractFactory("Ballot");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    ballot = await Ballot.deploy();
    ballotAddress = ballot.address;
    provider = await ethers.getDefaultProvider();
  });

  describe("Deployment", function () {
    
    it("Should set the right owner", async function () {
    
      expect(await ballot.owner()).to.equal(owner.address);
    });

  });


  describe("Proposals", function () {

    it("Set proposal and voting correctly", async () => {

      await ballot.setVote("One");
      await ballot.setProposal(0,"Jonny",addr1.address);
      await ballot.startVoting(0);

     await ballot.connect(addr1).vote(0,0, { value: ethers.utils.parseEther("0.01") })

      const winner = await ballot.winnerName(0);
      winner.should.equal("Jonny");

   });

   it("Withdraw after voting", async () => {  //this test doesn't work

    await ballot.setVote("One");
    await ballot.setProposal(0,"Jonny",addr1.address);
    await ballot.startVoting(0);


    expect(await provider.getBalance(ballotAddress)).to.equal(600000000000000000); 

    await ballot.connect(addr1).vote(0,0, { value: ethers.utils.parseEther("0.01") })

    expect(await provider.getBalance(ballotAddress)).to.equal(600000000000000000); 
    await ballot.withdrawAll();

   // expect(await provider.getBalance(owner.address)).to.equal(10000000000000); 

 });

  });


  describe("Vote", function () {

  it("Set Vote correctly", async () => {
    await ballot.setVote("One");
    let vote = await ballot.votes(0);
    vote.name.toString().should.equal("One");
   
});

it("Check is vote started", async () => {
  await ballot.setVote("One");
  const vote = await ballot.votes(0);
  vote.isStarted.should.equal(false);
  await ballot.startVoting(0);
  const startedVote = await ballot.votes(0);
  startedVote.isStarted.should.equal(true);
 
});

it("Check complete voting correctly", async () => {
  await ballot.setVote("One");
  await ballot.startVoting(0);
  
  await expect(ballot.completeTheVote(0)).to.be.revertedWith(
      "Voting continues"
    )

 
});


  });


});
  

 
