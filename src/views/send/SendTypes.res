type currencyData = {
  symbol: string,
  contract: string,
  tokenId: string,
}

type decimals = int

type currency = CurrencyTez | CurrencyToken(currencyData, decimals)

type assetType = CurrencyAsset(currency) | NftAsset(currencyData, Token.nftMetadata)
let isNft = (a: assetType) =>
  switch a {
  | NftAsset(_, _) => true
  | _ => false
  }

type formState = {recipient: option<Pkh.t>, prettyAmount: string, assetType: assetType}
