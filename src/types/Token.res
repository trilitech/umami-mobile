type metadata = {
  name: string,
  description: option<string>,
  displayUri: option<string>,
  thumbnailUri: option<string>,
}

type address = {address: string}
type token = {
  id: int,
  contract: address,
  metadata: metadata,
}

type t = {
  id: int,
  balance: string,
  account: address,
  token: token,
}
