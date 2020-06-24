var contract;
var account;
var address;
var ens;
var name = 'rps.larsmeulenbroek.eth';
var contract;

function setConnectedAccount(address) {
    var connectedAccount = document.getElementById('account');
    connectedAccount.innerHTML = `Connected with: ${address}`;
}

async function setNetworkType() {
    var connectedNetwork = document.getElementById('network');
    connectedNetwork.innerHTML = `Network: ${await web3.eth.net.getNetworkType()}`;
}

async function getAccountInfo() {
    var earnings = await contract.methods.getMyEarnings().call({from: account});
    log(`This account has ${earnings} earnings`);


    var losses = await contract.methods.getMyLosses().call({from: account});
    log(`This account has ${losses} losses`);
}

async function ConnectWeb3() {
    const web3Connect = new Web3Connect.Core({
        network: "rinkeby", // optional
        providerOptions: {
            walletconnect: {
                package: WalletConnectProvider,
                options: { infuraId: "0" } // dummy infura code!!
            }
        }
    });
    web3Connect.toggleModal();
    web3Connect.on("connect", OnConnect);
}
async function OnConnect(provider) {
    const web3 = new Web3(provider); // add provider to web3
    var acts=await web3.eth.getAccounts().catch(log);
    log(`Provider: ${Web3Connect.getInjectedProviderName()}`);
    log(`Mobile: ${Web3Connect.isMobile()}`);
    log(`Here are the accounts: ${JSON.stringify(acts)}`);
    account = acts[0];
    setConnectedAccount(account);
}

function log(str) {
    document.getElementById("log").innerHTML += '<p>' + str + '</p>';
}

async function init() {
    ConnectWeb3();
    setNetworkType();
    ethereum.on("accountsChanged", setConnectedAccount);
    ethereum.on("chainIdChanged", setNetworkType);
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
        await ethereum.enable();
        web3 = await new Web3(Web3.givenProvider);
        init();
    }
}
