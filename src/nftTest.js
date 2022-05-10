import {TezosToolkit} from '@taquito/taquito';
import {InMemorySigner} from '@taquito/signer';

let nodeUrl = 'https://ithacanet.smartpy.io/';
let Tezos = new TezosToolkit(nodeUrl);

let pk =
  'edesk1fTWHmsfmXWQSZeY8KzASsZS7AaaECjdF4r8YgVFuNjZdsMUCPa5wMX4NJpriaDaQb3rxNMk8gU3LdTKVse';

let passphrase = '1111';

let testNft = async () => {
  let theirs = 'tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5';
  let ours = 'tz1TCNGNizkMGj4FAS7Lvm9VwYdGeq2QLugb';

  console.log('smoke');
  let contractAddress = 'KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob';

  const transfer_params = [
    {
      from_: ours,
      txs: [
        {
          to_: theirs,
          token_id: 8,
          amount: 1,
        },
      ],
    },
  ];
  let res = await Tezos.tz.getBalance(ours);
  console.log('balance', res);

  Tezos.setProvider({
    signer: await InMemorySigner.fromSecretKey(pk, passphrase),
  });

  const contract = await Tezos.wallet.at(contractAddress);
  console.log('ok');
  console.log(contract);
  const op = await contract.methods.transfer(transfer_params).send();
  let result = await op.confirmation();
  console.log('result', result);
};

// let getContractNfts = async address => {
//     const contract = await Tezos.wallet.at(contractAddress)
// };

testNft();
