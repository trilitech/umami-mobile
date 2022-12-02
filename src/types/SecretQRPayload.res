type recoveryPhraseData = {
  salt: string,
  iv: string,
  data: string,
}
module JSON = {
  type t = {
    derivationPath: string,
    recoveryPhrase: recoveryPhraseData,
  }

  module Decode = {
    open JsonCombinators.Json.Decode

    let recoveryPhraseData = object(field => {
      salt: field.required(. "salt", string),
      iv: field.required(. "iv", string),
      data: field.required(. "data", string),
    })

    let qrPayload = object(field => {
      derivationPath: field.required(. "derivationPath", string),
      recoveryPhrase: field.required(. "recoveryPhrase", recoveryPhraseData),
    })

    let decode = (data: string) =>
      SafeJSON.parse(data)->Belt.Result.flatMap(d => d->JsonCombinators.Json.decode(qrPayload))
  }
}

type t = {
  derivationPath: DerivationPath.t,
  recoveryPhrase: recoveryPhraseData,
}

let fromJson = (json: JSON.t) => {
  DerivationPath.build(json.derivationPath)->Belt.Result.map(d => {
    recoveryPhrase: json.recoveryPhrase,
    derivationPath: d,
  })
}

let fromString = str => str->JSON.Decode.decode->Belt.Result.flatMap(fromJson)
