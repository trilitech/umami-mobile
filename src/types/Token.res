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
  metadata: metadata,
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
