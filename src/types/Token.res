module JSON = {
  type metadata = {
    name: string,
    symbol: option<string>,
    description: option<string>,
    displayUri: option<string>,
    thumbnailUri: option<string>,
    creators: option<array<string>>,
    decimals: string,
  }

  type address = {address: string}

  type token = {
    id: int,
    tokenId: string,
    contract: address,
    metadata: option<metadata>,
    standard: string,
  }

  type t = {
    id: int,
    balance: string,
    account: address,
    token: token,
  }

  let getNftUrl = (ipfsUrl: string) =>
    ipfsUrl->Js.String2.replace("ipfs://", "https://ipfs.io/ipfs/")

  let matchNftFields = metadata => {
    let {displayUri, thumbnailUri, description} = metadata

    switch (displayUri, thumbnailUri, description) {
    | (Some(displayUri), Some(thumbnailUri), Some(description)) =>
      Some((displayUri, thumbnailUri, description))
    | _ => None
    }
  }
}

type tokenBase = {
  id: int,
  balance: int,
  tz1: string,
  tokenId: string, // on tzkt, fa1.2 tokens have a tokenId
  contract: string,
}

type nftMetadata = {
  name: string,
  symbol: string,
  displayUri: string,
  thumbnailUri: string,
  description: string,
  creators: array<string>,
}

type fa2TokenMetadata = {
  name: string,
  symbol: string,
  decimals: int,
}

type tokenNFT = (tokenBase, nftMetadata)

type tokenFA2 = (tokenBase, fa2TokenMetadata)

// type faTokens = FA2(tokenFA2) | FA1(tokenBase)
type t = FA2(tokenFA2) | NFT(tokenNFT) | FA1(tokenBase)

let filterNFTs = (arr: array<t>) =>
  arr
  ->Belt.Array.map(token =>
    switch token {
    | NFT(nftData) => Some(nftData)
    | _ => None
    }
  )
  ->Helpers.filterNone

open Belt
let decodeJSON = (token: JSON.t) => {
  token.balance
  ->Int.fromString
  ->Option.flatMap(balance => {
    let base = {
      id: token.id,
      balance: balance,
      tz1: token.account.address,
      contract: token.token.contract.address,
      tokenId: token.token.tokenId,
    }

    token.token.metadata->Option.mapWithDefault(Some(FA1(base)), metadata =>
      switch JSON.matchNftFields(metadata) {
      // Nfts MUST have displayUrl, thumbnailUri, description
      | Some(displayUri, thumbnailUri, description) =>
        NFT((
          base,
          {
            name: metadata.name,
            symbol: metadata.symbol->Option.getWithDefault("FKR"),
            displayUri: displayUri->JSON.getNftUrl,
            thumbnailUri: thumbnailUri->JSON.getNftUrl,
            description: description,
            creators: metadata.creators->Belt.Option.getWithDefault([]),
          },
        ))->Some

      | None =>
        // FA2 tokens MUST have a symbol
        Helpers.both(metadata.decimals->Int.fromString, metadata.symbol)->Option.map(((
          decimals,
          symbol,
        )) => {
          FA2((base, {name: metadata.name, symbol: symbol, decimals: decimals}))
        })
      }
    )
  })
}
let decodeJsonArray = arr => arr->Belt.Array.map(decodeJSON)->Helpers.filterNone

let matchBase = (t: t) => {
  switch t {
  | FA2(base, _) => base
  | FA1(base) => base
  | NFT((base, _)) => base
  }
}

let positiveBalance = (t: t) => matchBase(t).balance > 0

let fromRaw = (amount: int, decimals: int) => {
  let divider = Js.Math.pow_float(~base=10., ~exp=decimals->Belt.Int.toFloat)->Belt.Float.toInt
  amount->Belt.Int.toFloat /. divider->Belt.Int.toFloat
}

let toRaw = (amount: float, decimals: int) => {
  let divider = Js.Math.pow_float(~base=10., ~exp=decimals->Belt.Int.toFloat)
  (amount *. divider)->Belt.Float.toInt
}

let isNft = (token: t) => {
  switch token {
  | NFT(_) => true
  | _ => false
  }
}

type nftInfo = {
  tokenId: string,
  contract: string,
  balance: int,
}

let getNftInfo = (nft: tokenNFT) => {
  let (b, _) = nft
  {tokenId: b.tokenId, contract: b.contract, balance: b.balance}
}
