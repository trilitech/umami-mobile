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

let isNft = (token: t) => matchNftData(token)->Belt.Option.isSome
