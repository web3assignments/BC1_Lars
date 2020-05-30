const Web3 = require('web3');
const web3http = new Web3('http://localhost:7545');
const web3ws = new Web3('ws://localhost:7545');
const badgeBuild = require('./build/contracts/BadgeGenerator');

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

    const owner = await badgeContract.methods.owner().call();

    console.log(`Contract owner: ${owner}`);

    console.log(owner)

    var isCreator = await badgeContract.methods.creators(accounts[1]).call();
    console.log(`${accounts[1]} is creator: ${isCreator}`)

    if (!isCreator) {
        console.log(`Add ${accounts[1]} to creators`);
        await badgeContract.methods.addCreator(accounts[1]).send({from: owner});

        await badgeContract.methods.creators(accounts[1]).call()
            .then((result) => {
                if (result) {
                    console.log(`${accounts[1]} is creator: ${result}`)
                }
            })
    }


    await badgeContract.methods.createBadge('test.json').send({from: owner})
        .then((result) => {
            console.log(`token created with id: ${result}`)
        })

    subscription.unsubscribe(function (error, success) {
        if (success) {
            console.log('Successfully unsubscribed!');
        } else if (error) {
            console.log('Unsubscribe failed');
            console.log(error);
        }
    });
}

start();
