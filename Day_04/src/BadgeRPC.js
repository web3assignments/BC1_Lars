const Web3 = require('web3');
const web3http = new Web3('http://localhost:7545');
const web3ws = new Web3('ws://localhost:7545');
const badgeBuild = require('../truffle/build/contracts/Badge');

const badgeAddress = badgeBuild.networks['5777'].address;
const ABILogTypes = [
    {"indexed": false, "internalType": "string", "name": "answer", "type": "string"}
]
const badgeABI = badgeBuild.abi;

async function start() {
    const badgeContract = new web3http.eth.Contract(badgeABI, badgeAddress);
    const accounts = await web3http.eth.getAccounts();

    console.log(accounts);

    const subscription = web3ws.eth.subscribe('logs', {fromBlock: '0x0', address: badgeAddress})
        .on("data", function (log) {
            var decoded = web3ws.eth.abi.decodeParameters(ABILogTypes, log.data);
            console.log(`Accepted answer: ${decoded[0]}`);
        });

    const owner = await badgeContract.methods.owner().call()
        .then((result) => {
        });

    console.log(`Contract owner: ${result}`);

    console.log(owner)

    await badgeContract.methods.canCreateToken(accounts[1]).call()
        .then((result) => {
            console.log(`${accounts[1]} is creator: ${result}`)
        })

    console.log(`Add ${accounts[1]} to creators`);
    await badgeContract.methods.addCreator(accounts[1]).send({from: owner});

    // await badgeContract.methods.canCreateToken(accounts[1]).call()
    //     .then((result) => {
    //         console.log(`${accounts[1]} is creator: ${result}`)
    //     })

    // console.log(Web3.utils.toBN(100).toString());
    //
    // await badgeContract.methods.create(new BigInt(100), 'test.json').send({from: accounts[1]})
    //     .then((result) => {
    //         console.log(`token created with id: ${result}`)
    //     })

    // console.log(`Upvoting ${accounts[1]} with 1`);
    // await badgeContract.methods.upVote(accounts[1], 1)
    //     .send({from: owner});
    // console.log(`Accepting answer from ${accounts[1]}`);
    // await badgeContract.methods.acceptAnswer(accounts[1],"Question","Great answer")
    //     .send({from: owner});
    //
    // console.log(`looking up reputation off ${accounts[1]}`);
    // await badgeContract.methods.participantReputation(accounts[1]).call()
    //     .then((result) => {``
    //         console.log(`${accounts[1]} has a reputation off ${result}`);
    //     });

    subscription.unsubscribe(function (error, success) {
        if (success) {
            console.log('Successfully unsubscribed!');
        } else if (error){
            console.log('Unsubscribe failed');
            console.log(error);
        }
    });
}

start();
