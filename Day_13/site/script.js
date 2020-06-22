var contract;
var account;
var address;
var ens;
var name = 'rps.larsmeulenbroek.eth';
var contract;

function getConnectedAccount(address) {
    var connectedAccount = document.getElementById('account');
    connectedAccount.innerHTML = `Connected with: ${address}`;
}

async function getNetworkType() {
    var connectedNetwork = document.getElementById('network');
    connectedNetwork.innerHTML = `Network: ${await web3.eth.net.getNetworkType()}`;
}

async function getAccountInfo() {
    var earnings = await contract.methods.getMyEarnings().call({from: account});
    log(`This account has ${earnings} earnings`);


    var losses = await contract.methods.getMyLosses().call({from: account});
    log(`This account has ${losses} losses`);
}

function log(str) {
    document.getElementById("log").innerHTML += '<p>' + str + '</p>';
}

async function init() {
    getConnectedAccount(account);
    getNetworkType();
    ethereum.on("accountsChanged", getConnectedAccount);
    ethereum.on("chainIdChanged", getNetworkType);
    ethereum.autoRefreshOnNetworkChange = false;


    const ens = await ENS(web3.currentProvider);
    var ResolverContract = await ens.resolver(name);

    if (ResolverContract) {
        contract = new web3.eth.Contract(RPSABI, await ResolverContract.addr());
        console.log(contract);
        log(`found contract with ens on: ${contract._address}`)
    }
}

window.onload = async function() {
    if (typeof web3 === "undefined") {
        window.alert("metamask not detected");
    } else {
        const accounts = await ethereum.enable();
        account = accounts[0];
        web3 = await new Web3(Web3.givenProvider);
        init();
    }
}
