const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic = "island follow among vintage course bronze truly sword body reform road business critic vacuum verb";

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "5777",
        },

        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/v3/5d6d200f83ee454c93bb9f4fe67650c3")
            },
            network_id: 3
        }
    },
    compilers: {
        solc: {
            version: "0.5.12",    // Fetch exact version from solc-bin (default: truffle's version)
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    }
};
