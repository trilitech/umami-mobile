import {Tzip12Module, tzip12} from '@taquito/tzip12';

export const getMetadata = async (Tezos, contractAddress, tokenId) => {
  Tezos.addExtension(new Tzip12Module());

  const contract = await Tezos.contract.at(contractAddress, tzip12);
  return contract.tzip12().getTokenMetadata(tokenId);
};
