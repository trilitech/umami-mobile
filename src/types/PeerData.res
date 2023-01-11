type t = string

let toString = (pkh: t): string => pkh

let unsafeBuild = (str: string): t => str

let buildFromUri = str => {
  // TODO refactor
  let regex = %re("/^(umami|tezos):\/\/\?type=tzip10&data=/")
  let contains = str->Js.String2.search(regex) !== -1
  contains ? str->Js.String2.replaceByRe(regex, "")->Some : None
}
