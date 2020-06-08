const Codex = artifacts.require('Codex');

require('chai').should();

contract('Codex', accounts => {
    const _name = 'Codex';
    const _symbol = 'CDX';

    beforeEach(async function() {
        this.token = await Codex.new(_name, _symbol);
    });

    describe('token attributes', function(){
        it('has correct name', async function () {
            const name = await this.token.name();
            name.should.equal(_name);
        })

        it('has correct symbol', async function () {
            const symbol = await this.token.symbol();
            symbol.should.equal(_symbol);
        })
    })
})
