type t = Tez(int) | Token(Token.t)

let toPretty = (amount: t) => {
  switch amount {
  | Tez(amount) => Token.fromRaw(amount, Constants.tezCurrencyDecimal)
  | Token(token) =>
    switch token {
    | FA2(d, m) => Token.fromRaw(d.balance, m.decimals)
    | NFT(d, _) => d.balance->Belt.Int.toFloat
    | FA1(d) => Token.fromRaw(d.balance, Constants.fa1CurrencyDecimal)
    }
  }
}
