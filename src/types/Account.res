type t = {
  name: string,
  balance: option<int>,
  tz1: Pkh.t,
  pk: string,
  sk: string,
  derivationPathIndex: int,
  tokens: array<Token.t>,
  transactions: array<Operation.t>,
}

let changeName = (a, name) => {...a, name: name}

let make = (
  ~tz1,
  ~pk,
  ~sk,
  ~derivationPathIndex,
  ~name=?,
  ~balance=?,
  ~tokens=[],
  ~transactions=[],
  (),
) => {
  derivationPathIndex: derivationPathIndex,
  pk: pk,
  sk: sk,
  tz1: tz1,
  name: name->Belt.Option.getWithDefault("Account " ++ Js.Int.toString(derivationPathIndex)),
  balance: balance,
  tokens: tokens,
  transactions: transactions,
}
