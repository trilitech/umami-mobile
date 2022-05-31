external unsafeToOperationJSON: Js.Json.t => Operation.JSON.t = "%identity"

let getTransactions = tz1 => {
  Fetch.fetch(`https://ithacanet.umamiwallet.com/accounts/${tz1}/operations`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeToOperationJSON))
  ->Promise.thenResolve(Operation.handleJSONArray)
}

external unsafeToBlockJSON: Js_dict.t<Js.Json.t> => {"indexer_last_block": int} = "%identity"

let getIndexerLastBlock = () =>
  Fetch.fetch("https://ithacanet.umamiwallet.com/monitor/blocks")
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(json => unsafeToBlockJSON(json)["indexer_last_block"])
