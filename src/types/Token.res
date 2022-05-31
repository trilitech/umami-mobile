type metadata = {
  name: string,
  symbol: string,
  description: option<string>,
  displayUri: option<string>,
  thumbnailUri: option<string>,
  creators: option<string>,
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

let getNftUrl = (ipfsUrl: string) => ipfsUrl->Js.String2.replace("ipfs://", "https://ipfs.io/ipfs/")

let matchNftData = (metadata: option<metadata>) => {
  switch metadata {
  | Some(metadata) => {
      let {displayUri, thumbnailUri, description} = metadata
      switch (displayUri, thumbnailUri, description) {
      | (Some(displayUri), Some(thumbnailUri), Some(description)) =>
        Some((displayUri, thumbnailUri, description, metadata.name))
      | _ => None
      }
    }
  | None => None
  }
}

let matchNftFields = metadata => {
  let {displayUri, thumbnailUri, description, creators} = metadata

  switch (displayUri, thumbnailUri, description, creators) {
  | (Some(displayUri), Some(thumbnailUri), Some(description), Some(creators)) =>
    Some((displayUri, thumbnailUri, description, creators))
  | _ => None
  }
}

let isNft = (token: t) => matchNftData(token.token.metadata)->Belt.Option.isSome

type tokenBase = {
  id: int,
  balance: int,
  account: address,
  tokenId: string,
  contract: string,
}

type nftMetadata = {
  name: string,
  symbol: string,
  displayUri: string,
  thumbnailUri: string,
  description: string,
  creators: string,
}

type fa2TokenMetadata = {
  name: string,
  symbol: string,
  decimals: int,
}

type tokenNFT = (tokenBase, nftMetadata)
type tokenFA2 = (tokenBase, fa2TokenMetadata)

// type faTokens = FA2(tokenFA2) | FA1(tokenBase)
type allTokens = FA2(tokenFA2) | NFT(tokenNFT) | FA1(tokenBase)

let filterNFTs = (arr: array<allTokens>) =>
  arr
  ->Belt.Array.map(token =>
    switch token {
    | NFT(nftData) => Some(nftData)
    | _ => None
    }
  )
  ->Helpers.filterNone

open Belt
let decodeJSON = (token: t) => {
  token.balance
  ->Int.fromString
  ->Option.flatMap(balance => {
    let base = {
      id: token.id,
      balance: balance,
      account: token.account,
      contract: token.token.contract.address,
      tokenId: token.token.tokenId,
    }

    token.token.metadata->Option.mapWithDefault(Some(FA1(base)), metadata =>
      switch matchNftFields(metadata) {
      | Some(displayUri, thumbnailUri, description, creators) =>
        NFT((
          base,
          {
            name: metadata.name,
            symbol: metadata.symbol,
            displayUri: displayUri,
            thumbnailUri: thumbnailUri,
            description: description,
            creators: creators,
          },
        ))->Some
      | None =>
        metadata.decimals
        ->Int.fromString
        ->Option.map(decimals => {
          FA2((base, {name: metadata.name, symbol: metadata.symbol, decimals: decimals}))
        })
      }
    )
  })
}
let decodeJsonArray = arr => arr->Belt.Array.map(decodeJSON)->Helpers.filterNone

let matchBase = (t: allTokens) => {
  switch t {
  | FA2(base, _) => base
  | FA1(base) => base
  | NFT((base, _)) => base
  }
}

let positiveBalance = (t: allTokens) => {
  matchBase(t).balance > 0
}

let fromRaw = (amount: int, decimals: int) => {
  let divider = Js.Math.pow_float(~base=10., ~exp=decimals->Belt.Int.toFloat)->Belt.Float.toInt
  amount / divider
}

let toRaw = (amount: int, decimals: int) => {
  let divider = Js.Math.pow_float(~base=10., ~exp=decimals->Belt.Int.toFloat)->Belt.Float.toInt
  amount * divider
}
