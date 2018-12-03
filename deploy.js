const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletProvider(
  'captain raven floor sorry broom meadow merit addict flip argue member donate',
  'https://rinkeby.infura.io/v3/9013a0bef7c54af4b847f2517ab3b6cb'
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ gas: '2000000', from: accounts[0] });

  console.log(interface);    
  console.log('Contract deployed to', result.options.address);
};
deploy();
