import {Injectable} from '@angular/core';
import {environment} from '../../environments/environment';
import {Badge} from '../models/badge';

const Web3 = require('web3');

declare let require: any;
declare let window: any;

const BadgeAbi = require('../../../truffle/build/contracts/BadgeGenerator.json');


@Injectable({
  providedIn: 'root'
})
export class Web3Service {

  public account: any = null;
  public readonly web3: any;

  private enable: any;
  private contract: any;

  public owner: any;
  public badgeCount: any;
  public isCreator: boolean;
  public badges: Badge[];

  constructor() {
    this.badges = [];
    if (window.ethereum === undefined) {
      alert('Non-Ethereum browser detected. Install MetaMask');
    } else {
      if (typeof window.web3 !== 'undefined') {
        this.web3 = window.web3.currentProvider;
      } else {
        this.web3 = new Web3.providers.HttpProvider(environment.web3HttpProvider);
      }
      window.web3 = new Web3(window.ethereum);
      this.enable = this.enableMetaMaskAccount();

      this.getAccount().then((account) => {
        this.account = account;
        this.getContract();
      });

      // detect metamask change
      setInterval(() => {
        this.getAccount().then((account) => {
          if (account !== this.account) {
            this.account = account;
            this.badges = [];
            this.isCreator = null;
            this.getContract();
          }
        });
      }, 1000);
    }
  }

  private async enableMetaMaskAccount(): Promise<any> {
    let enable = false;
    await new Promise((resolve, reject) => {
      enable = window.ethereum.enable();
    });
    return Promise.resolve(enable);
  }

  private async getContract() {
    // set badge contract
    const networkId = await window.web3.eth.net.getId();
    const networkData = BadgeAbi.networks[networkId];
    if (networkData) {
      const abi = BadgeAbi.abi;
      const address = networkData.address;
      this.contract = new window.web3.eth.Contract(abi, address);
      this.getBlockChainData();
    }

  }

  private async getAccount(): Promise<any> {
    return await new Promise((resolve, reject) => {
      window.web3.eth.getAccounts((err, retAccount) => {
        if (retAccount.length > 0) {
          resolve(retAccount[0]);
        } else {
          reject('No accounts found.');
        }
        if (err != null) {
          reject('Error retrieving account');
        }
      });
    }) as Promise<any>;
  }

  private async getBlockChainData() {
    // Get owner of Contract
    this.contract.methods.owner().call().then((owner) => {
      this.owner = owner;
    }).catch((err) => {
      console.error(err);
    });

    // Get existing badges of Contract
    this.contract.methods.badgeCount().call().then((count) => {
      this.badgeCount = count;
      for (let i = 0; i < count; i++) {
        // Get existing badges of Contract
        this.contract.methods.badges(i).call().then((badge) => {
          const tmpBadge: Badge = {
            id: badge.id,
            owner: badge.owner,
            metadataUrl: badge.metadataUrl
          };
          this.badges.push(tmpBadge);
        }).catch((err) => {
          console.error(err);
        });
      }
    }).catch((err) => {
      console.error(err);
    });

    // Get existing badges of Contract
    this.contract.methods.creators(this.account).call().then((bool) => {
      console.log(bool);
      this.isCreator = bool;
    }).catch((err) => {
      console.error(err);
    });
  }

  public async createBadge(data): Promise<any> {
    return await new Promise((resolve, reject) => {
      this.contract.methods.createBadge(data).send({from: this.account}).then((res) => {
        resolve(res);
      }).catch((err) => {
        console.error(err);
        reject('Could not create Badge');
      });
    }) as Promise<any>;
  }

  public async addCreator(data): Promise<any> {
    return await new Promise((resolve, reject) => {
      this.contract.methods.addCreator(data).send({from: this.account}).then((res) => {
        if (data === this.account) {
          this.isCreator = true;
        }
        resolve(res);
      }).catch((err) => {
        console.error(err);
        reject('Could not add creator with address: ' + data);
      });
    }) as Promise<any>;
  }

  public async removeCreator(data): Promise<any> {
    return await new Promise((resolve, reject) => {
      this.contract.methods.removeCreator(data).send({from: this.account}).then((res) => {
        if (data === this.account) {
          this.isCreator = false;
        }
        resolve(res);
      }).catch((err) => {
        console.error(err);
        reject('Could not remove creator with address: ' + data);
      });
    }) as Promise<any>;
  }
}
