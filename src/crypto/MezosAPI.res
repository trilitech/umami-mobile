external unsafeToOperationJSON: Js.Json.t => Operation.JSON.t = "%identity"

let getUmamiWalletHost = isTestNet =>
  isTestNet ? Endpoints.umamiWallet.testNet : Endpoints.umamiWallet.mainNet

exception MezosTransactionFetchFailure(string)
exception MezosLastBlockFetchFailure(string)

let getTransactions = (~tz1, ~isTestNet) => {
  Fetch.fetch(`https://${getUmamiWalletHost(isTestNet)}/accounts/${tz1}/operations`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeToOperationJSON))
  ->Promise.thenResolve(Operation.handleJSONArray)
  ->Promise.catch(err => Promise.reject(MezosTransactionFetchFailure(err->Helpers.getMessage)))
}

external unsafeToBlockJSON: Js_dict.t<Js.Json.t> => {"indexer_last_block": int} = "%identity"

let getIndexerLastBlock = (~isTestNet) =>
  Fetch.fetch(`https://${getUmamiWalletHost(isTestNet)}/monitor/blocks`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(json => unsafeToBlockJSON(json)["indexer_last_block"])
  ->Promise.catch(err => Promise.reject(MezosLastBlockFetchFailure(err->Helpers.getMessage)))

%%private(
  let checkExists = (~tz1, ~isTestNet) => {
    let existsUrl = `https://${getUmamiWalletHost(isTestNet)}/accounts/${tz1}/exists`

    Fetch.fetch(existsUrl)
    ->Promise.then(Fetch.Response.json)
    ->Promise.thenResolve(Js.Json.decodeBoolean)
    ->Promise.thenResolve(Belt.Option.getExn)
  }
)

let checkExistsAllNetworks = (~tz1) => {
  Promise.all2((
    checkExists(~tz1, ~isTestNet=false),
    checkExists(~tz1, ~isTestNet=true),
  ))->Promise.thenResolve(((existsInTestNet, existsInMainNet)) =>
    existsInTestNet || existsInMainNet
  )
}
