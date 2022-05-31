export default async (
  Tezos,
  contractAddress,
  token_id,
  amount,
  sender,
  recipient,
) => {
  const transfer_params = [
    {
      from_: sender,
      txs: [
        {
          to_: recipient,
          token_id,
          amount,
        },
      ],
    },
  ];

  const contract = await Tezos.wallet.at(contractAddress);
  return contract.methods.transfer(transfer_params);
};
