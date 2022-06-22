type t = {
  name: string,
  balance: option<int>,
  tz1: string,
  pk: string,
  sk: string,
  derivationPathIndex: int,
  tokens: array<Token.t>,
  transactions: array<Operation.t>,
}

let changeName = (a, name) => {...a, name: name}
