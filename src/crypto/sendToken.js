export default async (
  Tezos,
  contractAddress,
  token_id,
  amount,
  sender,
  recipient,
  isFa1 = false,
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
  return isFa1
    ? contract.methods.transfer(sender, recipient, amount)
    : contract.methods.transfer(transfer_params);
};
