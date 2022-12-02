type t = {
  pk: string,
  content: string,
  sig: string,
}

let serialise = JSONparse.stringify

module Decode = {
  open JsonCombinators.Json.Decode

  let recoveryPhraseData = object(field => {
    pk: field.required(. "pk", string),
    content: field.required(. "content", string),
    sig: field.required(. "sig", string),
  })

  let fromString = (data: string) =>
    data
    ->SafeJSON.parse
    ->Belt.Result.flatMap(res => res->JsonCombinators.Json.decode(recoveryPhraseData))
}
