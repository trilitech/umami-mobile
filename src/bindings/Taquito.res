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

  @send external getBalance: (tz, string) => Promise.t<Js.Json.t> = "getBalance"
  @send external setProvider: (toolkit, 'a) => unit = "setProvider"
  @send external transfer: (contract, 'a) => Promise.t<operation> = "transfer"
}

@module("@taquito/taquito") @new
external create: string => Toolkit.toolkit = "TezosToolkit"

@module("custom-signer") @scope("InMemorySigner")
external fromSecretKey: (string, string) => Promise.t<signer> = "fromSecretKey"

@send external publicKeyHash: (signer, unit) => Promise.t<string> = "publicKeyHash"
