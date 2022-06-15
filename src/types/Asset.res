type t = Tez(int) | Token(Token.t)

let isTez = amount =>
  switch amount {
  | Tez(_) => true
  | _ => false
  }

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

let getSymbol = (a: t) => {
  switch a {
  | Tez(_) => "tez"
  | Token(t) =>
    switch t {
    | FA1(_) => "FA1.2"
    | FA2(_, m) => m.symbol
    | NFT(_, m) => m.symbol
    }
  }
}

let getBalance = (a: t) => {
  switch a {
  | Tez(amount) => amount
  | Token(t) => Token.getBalance(t)
  }
}
