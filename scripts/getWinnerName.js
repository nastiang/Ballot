const BALLOTABI = require('../abis/Ballot.json');
var express = require('express');
var Web3 = require('web3');
const Provider = require('@truffle/hdwallet-provider');

require('dotenv').config();

var app = express();
var port = process.env.PORT || 3000;

var SmartContractAddress = process.env.CONTRACT_ADDRESS;
var SmartContractABI = BALLOTABI;
var address = process.env.PUBLIC_KEY;
var privatekey = process.env.PRIVATE_KEY;
var rpcurl = process.env.WEB3_PROVIDER;

  const provider = new Provider(privatekey, rpcurl);

  var web3 = new Web3(provider);
  var myContract = new web3.eth.Contract(SmartContractABI, SmartContractAddress);

const sendData = async () => {


try{
 var receipt = await myContract.methods.winnerName(0).send({
  from: address
}).then(function(err, result){
  console.log(result) ;
  })
}catch(error){
  console.log(error)
}

}

sendData();

app.listen(port);
console.log('listening on', port);