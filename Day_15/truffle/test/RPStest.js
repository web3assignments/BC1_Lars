const RockPaperScissors = artifacts.require("RockPaperScissors");
const truffleAssert = require("truffle-assertions");

var Privileges = {USER: 0, ADMIN: 1, OWNER: 2};

contract("RockPaperScissor", async function (accounts) {

    let instance;

    before(async function () {
        instance = await RockPaperScissors.deployed();
    })

    it("Contract Deploys Successfully", async function () {
        contract = await RockPaperScissors.deployed();
        const address = contract.address;

        assert(address != '');
        assert(address != '0x0');
        assert(address != null);
        assert(address != undefined)
    });

    it("Should initialize correctly", async function () {
        let owner = await instance.owner();
        let privilege = await instance.getPrivilege({from: owner});
        assert(owner == accounts[0], "Deployer is not the owner");
        assert(privilege == Privileges.OWNER, "Owner does not have the right privilege");
    });

    it("Should set correct account privileges", async function () {
        let adminAccount = accounts[1];
        instance.setPrivilege(Privileges.ADMIN, adminAccount);
        let privilege = await instance.getPrivilege({from: adminAccount});
        assert(privilege == Privileges.ADMIN, "Privilege not set correctly");

        let userAccount = accounts[2];
        let role = await instance.getPrivilege({from: userAccount});
        assert(role == Privileges.USER, "Privilege not set correctly");
    });


    it("Should give USER access to available functions", async function () {
        let account = accounts[2];
        await truffleAssert.fails(instance.resetPlayerStats(accounts[3], {from: account}), truffleAssert.ErrorType.REVERT);
        await truffleAssert.passes(instance.getMyEarnings({from: account}));
    });

    it("Should give ADMIN access to available functions", async function () {
        let account = accounts[1];
        await truffleAssert.passes(instance.resetPlayerStats(accounts[3], {from: account}));
        await truffleAssert.passes(instance.getMyEarnings({from: account}));
    });

    it("Should revert because the user entered an invalid choice", async function () {
        await truffleAssert.fails(instance.play(5, {value: web3.utils.toWei("0.5", "ether")}), truffleAssert.ErrorType.REVERT);
    });

    it("Should revert value is lower than minimum bet", async function () {
        await truffleAssert.fails(instance.play(2, {value: web3.utils.toWei("0.02", "ether")}), truffleAssert.ErrorType.REVERT);
    });
});
