let formatTz1 = (tz1: string) => {
  let length = tz1->Js.String2.length
  tz1->Js.String2.slice(~from=0, ~to_=5) ++ "..." ++ tz1->Js.String2.slice(~from=-5, ~to_=length)
}

let formatBalance = (balance: int) => {
  let result = balance / Constants.currencyDivider
  result->Belt.Int.toString ++ " " ++ "tez"
}
