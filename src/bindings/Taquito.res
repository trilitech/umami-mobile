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

@module("./dummySigner")
external createDummySigner: string => signer = "create"

@module("custom-signer") @scope("InMemorySigner")
external fromSecretKey: (string, string) => Promise.t<signer> = "fromSecretKey"

@send external publicKeyHash: (signer, unit) => Promise.t<string> = "publicKeyHash"
