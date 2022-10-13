external unsafeToOperationJSON: Js.Json.t => Operation.JSON.t = "%identity"

let getUmamiWalletHost = isTestNet =>
  isTestNet ? Endpoints.umamiWallet.testNet : Endpoints.umamiWallet.mainNet

exception MezosTransactionFetchFailure(string)
exception MezosLastBlockFetchFailure(string)

let makeHeaders = () =>
  DeviceId.id.contents->Belt.Option.mapWithDefault(Fetch.RequestInit.make(~method_=Get, ()), id => {
    let headers = Fetch.HeadersInit.make({
      "UmamiInstallationHash": ShortHash.unique(id),
    })
    Fetch.RequestInit.make(~method_=Get, ~headers, ())
  })

let getTransactions = (~tz1: Pkh.t, ~isTestNet) => {
  Fetch.fetchWithInit(
    `https://${getUmamiWalletHost(isTestNet)}/accounts/${tz1->Pkh.toString}/operations`,
    makeHeaders(),
  )
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeToOperationJSON))
  ->Promise.thenResolve(Operation.handleJSONArray)
  ->Promise.catch(err => Promise.reject(MezosTransactionFetchFailure(err->Helpers.getMessage)))
}

external unsafeToBlockJSON: Js_dict.t<Js.Json.t> => {"indexer_last_block": int} = "%identity"

let getIndexerLastBlock = (~isTestNet) =>
  Fetch.fetchWithInit(`https://${getUmamiWalletHost(isTestNet)}/monitor/blocks`, makeHeaders())
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(json => unsafeToBlockJSON(json)["indexer_last_block"])
  ->Promise.catch(err => Promise.reject(MezosLastBlockFetchFailure(err->Helpers.getMessage)))

%%private(
  let checkExists = (~tz1, ~isTestNet) => {
    let existsUrl = `https://${getUmamiWalletHost(isTestNet)}/accounts/${tz1->Pkh.toString}/exists`

    Fetch.fetchWithInit(existsUrl, makeHeaders())
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
