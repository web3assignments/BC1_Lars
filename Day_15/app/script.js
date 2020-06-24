let contract, account, address, ens, eventSubscription, gameStarted, lastGameOption;
let name = 'rps.larsmeulenbroek.eth';

async function setHeaderInfo(address) {
    const headerInfo = document.getElementById('headerInfo');
    headerInfo.innerHTML = `(${await web3.eth.net.getNetworkType()}): ${address}`

}

async function updateAccountInfo() {
    let gameEarnings = document.getElementById('gameEarnings');
    let earnings = await contract.methods.getMyEarnings().call({from: account});
    gameEarnings.innerHTML = `My Total Earnings with this fun game are: ${web3.utils.fromWei(earnings, 'ether')} eth`;
}

async function playGame(option) {
    if (!gameStarted) {
        gameStarted = true;
        lastGameOption = option;
        log(`playing game with: ${getOption(option)}`);
        let element = document.getElementById('gameStarted');
        element.style.display = "block";
        await contract.methods.play(option).send({from: account, value: web3.utils.toWei('0.01', "ether")});
    } else {
        alert(`Already started a game with ${getChoice(lastGameOption)}`);
    }
}

function getOption(option) {
    switch (option) {
        case 1:
            return "Rock";
        case 2:
            return "Paper";
        case 3:
            return "Scissor";
    }
}

async function ConnectWeb3() {
    const web3Connect = new Web3Connect.Core({
        network: "rinkeby", // optional
        providerOptions: {
            walletconnect: {
                package: WalletConnectProvider,
                options: {infuraId: "0"} // dummy infura code!!
            }
        }
    });
    await web3Connect.toggleModal();
    web3Connect.on("connect", OnConnect);
}

async function OnConnect(provider) {
    const web3 = new Web3(provider); // add provider to web3
    var acts = await web3.eth.getAccounts().catch(log);
    log(`Provider: ${Web3Connect.getInjectedProviderName()}`);
    log(`Mobile: ${Web3Connect.isMobile()}`);
    log(`Here are the accounts: ${JSON.stringify(acts)}`);
    account = acts[0];
    await setHeaderInfo(account);
    await updateAccountInfo();
}

function log(str) {
    document.getElementById("log").innerHTML += '<p>' + str + '</p>';
}

async function init() {
    await ConnectWeb3();
    ethereum.on("accountsChanged", setHeaderInfo);
    ethereum.on("chainIdChanged", setHeaderInfo);
    ethereum.autoRefreshOnNetworkChange = false;


    const ens = await ENS(web3.currentProvider);
    let ResolverContract = await ens.resolver(name);

    if (ResolverContract) {
        contract = new web3.eth.Contract(RPSABI, await ResolverContract.addr());
        log(`found contract with ens on: ${contract._address}`);

        eventSubscription = contract.events.GameResult()
            .on('data', (event) => {
                log(`Game played`);
                if (parseInt(event.returnValues['result']) === lastGameOption) {
                    log(`Its a tie, the opponent player ${getChoice(parseInt(event.returnValues['result']))}`)
                } else {
                    if (event.returnValues['winner']) {
                        log(`You are a winner, the opponent played: ${getChoice(parseInt(event.returnValues['result']))}`)
                    } else {
                        log(`You are a loser, the opponent played: ${getChoice(parseInt(event.returnValues['result']))}`)
                    }
                }
                updateAccountInfo();
                let element = document.getElementById('gameStarted');
                element.style.display = "none";
                gameStarted = false;
            })
            .on('error', console.error);
    }
}

function getChoice(number) {
    switch (number) {
        case 1:
            return "Rock";
        case 2:
            return "Paper";
        case 3:
            return "Scissor";
    }
}

window.onload = async function () {
    if (typeof web3 === "undefined") {
        window.alert("metamask not detected");
    } else {
        await ethereum.enable();
        web3 = await new Web3(Web3.givenProvider);
        await init();
    }
};

window.onbeforeunload = function () {
    eventSubscription.unsubscribe();
};
