export const makeContract = async (Tezos, contractAddress, method, params) => {
  const contract = await Tezos.wallet.at(contractAddress);
  const result = contract.methods[method](params);
  return result;
};

export const makeFA1Contract = async (
  Tezos,
  contractAddress,
  amount,
  sender,
  recipient,
) => {
  const contract = await Tezos.wallet.at(contractAddress);
  const result = contract.methods.transfer(sender, recipient, amount);
  return result;
};
