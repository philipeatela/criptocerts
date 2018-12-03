const path = require('path');
const fs = require('fs');
const solc = require('solc');

const criptocertsPath  = path.resolve(__dirname, 'contracts', 'Criptocerts.sol');
const source = fs.readFileSync(criptocertsPath, 'utf8');

module.exports = solc.compile(source, 1).contracts[':Criptocerts'];
