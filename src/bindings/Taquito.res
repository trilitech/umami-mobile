type signer
module Toolkit = {
  type tz
  type contract
  type estimate
  type operation = {hash: string}

  type toolkit = {
    tz: tz,
    contract: contract,
    estimate: estimate,
  }

  type estimation = {
    suggestedFeeMutez: int,
    gasLimit: int,
  }

  @send external getBalance: (tz, string) => Promise.t<Js.Json.t> = "getBalance"
  @send external setProvider: (toolkit, 'a) => unit = "setProvider"
  @send external transfer: (contract, 'a) => Promise.t<operation> = "transfer"
  @send external estimateTransfer: (estimate, 'a) => Promise.t<estimation> = "transfer"
}

module Contract = {
  type transfer
  type transferParams

  @send external send: (transfer, unit) => Promise.t<'a> = "send"
  @send
  external toTransferParams: (transfer, unit) => transferParams = "toTransferParams"
}

@module("@taquito/taquito") @new
external create: string => Toolkit.toolkit = "TezosToolkit"

@module("@taquito/utils")
external validateAddress: string => int = "validateAddress"

@module("@taquito/utils")
external getPkhfromPk: string => string = "getPkhfromPk"

// Required for unpackDataBytes to work on RN
%raw("require('text-encoding-polyfill')")
@module("@taquito/michel-codec")
external unpackDataBytes: {"bytes": string} => {"string": string} = "unpackDataBytes"

@module("@taquito/utils")
external verifySignature: (~content: string, ~pk: string, ~sig: string) => bool = "verifySignature"

@module("./js/dummySigner")
external createDummySigner: (~pk: string, ~pkh: string) => signer = "create"

@module("custom-signer") @scope("InMemorySigner")
external fromSecretKey: (string, string) => Promise.t<signer> = "fromSecretKey"

@send external publicKeyHash: (signer, unit) => Promise.t<string> = "publicKeyHash"
@send external publicKey: (signer, unit) => Promise.t<string> = "publicKey"

type signed = {sig: string, prefixSig: string}
@send external sign: (signer, string) => Promise.t<signed> = "sign"
