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

let toPretty = (pkh: t) => pkh->toString->Helpers.formatHash()

let notKt = t => !Js.Re.test_(%re("/^kt/i"), t->toString)
