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

  let decode = (data: string) =>
    data->JsonCombinators.Json.parseExn->JsonCombinators.Json.decode(recoveryPhraseData)
}
