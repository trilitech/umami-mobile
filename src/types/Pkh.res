type t = string

let toString = (pkh: t): string => pkh

let unsafeBuild = (str: string): t => str

let tz1IsValid = address => Taquito.validateAddress(address) == 3

let build = (str: string): result<t, string> => {
  tz1IsValid(str) ? Ok(str) : Error(`Invalid tz1 address: ${str}`)
}

let buildFromPk = (pk: string) => Taquito.getPkhfromPk(pk)->unsafeBuild

let buildOption = (str: string): option<t> => {
  switch build(str) {
  | Ok(pkh) => Some(pkh)
  | Error(_) => None
  }
}

let formatTz1 = (tz1: string) => {
  let length = tz1->Js.String2.length
  tz1->Js.String2.slice(~from=0, ~to_=5) ++ "..." ++ tz1->Js.String2.slice(~from=-5, ~to_=length)
}
let toPretty = (pkh: t) => pkh->toString->formatTz1

let notKt = t => !Js.Re.test_(%re("/^kt/i"), t->toString)
