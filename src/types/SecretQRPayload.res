type recoveryPhraseData = {
  salt: string,
  iv: string,
  data: string,
}

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
    data->JsonCombinators.Json.parseExn->JsonCombinators.Json.decode(qrPayload)
}

let make = str => {
  let result = Decode.decode(str)
  switch result {
  | Ok(result) =>
    result.derivationPath != "m/44'/1729'/?'/0'"
      ? Error(`Unsupported derivation path: ${result.derivationPath}`)
      : Ok(result)
  | Error(e) => Error(e)
  }
}
