let formatTz1 = (tz1: string) => {
  let length = tz1->Js.String2.length
  tz1->Js.String2.slice(~from=0, ~to_=5) ++ "..." ++ tz1->Js.String2.slice(~from=-5, ~to_=length)
}

let formatBalance = (balance: int) => {
  let result = Belt.Int.toFloat(balance) /. 1000000.
  result->Belt.Float.toString ++ " " ++ "tez"
}
