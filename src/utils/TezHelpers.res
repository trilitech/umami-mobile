let formatBalance = (balance: int) => {
  let result = Token.fromRaw(balance, Constants.tezCurrencyDecimal)
  result->Belt.Float.toString ++ " " ++ "tez"
}
