type metadata = {
  name: string,
  description: option<string>,
  displayUri: option<string>,
  thumbnailUri: option<string>,
}

type address = {address: string}
type token = {
  id: int,
  tokenId: string,
  contract: address,
  metadata: option<metadata>,
}

type t = {
  id: int,
  balance: string,
  account: address,
  token: token,
}

let getNftUrl = (ipfsUrl: string) => ipfsUrl->Js.String2.replace("ipfs://", "https://ipfs.io/ipfs/")

let hasNfts = (tokens: array<t>) =>
  tokens
  ->Belt.Array.keep(t => {
    switch t.balance->Belt.Int.fromString {
    | Some(b) => b > 0
    | None => false
    }
  })
  ->Belt.Array.length > 0

let matchNftData = (token: t) => {
  switch token.token.metadata {
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
