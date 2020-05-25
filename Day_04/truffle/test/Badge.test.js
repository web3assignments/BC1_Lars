const Badge = artifacts.require('./Badge.sol');

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('Badge', (accounts) => {
    describe('deployment', async () => {
        it('deploys successfully', async () => {
            contract = await Badge.deployed();
            const address = contract.address;
            assert.notEqual(address, '');
            assert.notEqual(address, '0x0');
            assert.notEqual(address, null);
            assert.notEqual(address, undefined)
        })
    });
    describe('create', async () => {
        it('create new token', async () => {
            const result = await contract.create(100, "test.json");
            // SUCCESS
            const event = result.logs[0].args;
            assert.equal(event._id.toNumber(), 1, 'id is correct');
            assert.equal(event._from, '0x0000000000000000000000000000000000000000', 'from is correct');
            assert.equal(event._to, accounts[0], 'to is correct');
        })
    });

    describe('indexing', async () => {
        it('list badges', async () => {
            // create 3 more badge tokens
          await contract.create(100, "test2.json");
          await contract.create(100, "test3.json");
          await contract.create(100, "test4.json");


            const totalSupply = await contract.nonce;
            assert.equal(totalSupply, 4);
        })
    })
});
