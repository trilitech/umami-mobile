type t = {
  name: string,
  balance: option<int>,
  tz1: string,
  sk: string,
  derivationPathIndex: int,
  tokens: array<Token.allTokens>,
  transactions: array<Operation.t>,
}
