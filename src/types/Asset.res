type t = Tez(int) | Token(Token.t)

type tokenName = CurrencyName(string) | NFTname(string, string)

let toPrettyAmount = (amount: t) => {
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

let getSymbol = (amount: t) => {
  switch amount {
  | Tez(_) => CurrencyName("tez")
  | Token(t) =>
    switch t {
    | FA2(_, m) => CurrencyName(m.symbol)
    | NFT(_, m) => NFTname(m.symbol, m.thumbnailUri)
    | FA1(_) => CurrencyName("KLD")
    }
  }
}

let getPrettyString = (amount: t) => {
  let prettyAmount = toPrettyAmount(amount)->Belt.Float.toString
  let name = getSymbol(amount)
  switch name {
  | CurrencyName(name) => prettyAmount ++ " " ++ name

  | NFTname(_) => prettyAmount
  }
}

let isTez = a =>
  switch a {
  | Tez(_) => true
  | Token(_) => false
  }

let isToken = a => !isTez(a)

let isNft = amount =>
  switch amount {
  | Tez(_) => false
  | Token(t) => Token.isNft(t)
  }

let getTokenBase = (a: t) =>
  switch a {
  | Tez(_) => None
  | Token(t) =>
    switch t {
    | NFT(_) => None
    | FA2((b, _)) => b->Some
    | FA1(b) => b->Some
    }
  }

let getStandard = (a: t) =>
  switch a {
  | Tez(_) => None
  | Token(t) =>
    switch t {
    | NFT(_) => "fa2"->Some
    | FA2((_, _)) => "fa2"->Some
    | FA1(_) => "fa1.2"->Some
    }
  }
