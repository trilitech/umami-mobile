external unsafeParse: Js.Json.t => Operation.JSON.t = "%identity"

let getTransactions = tz1 => {
  Fetch.fetch(`https://ithacanet.umamiwallet.com/accounts/${tz1}/operations`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeParse))
  ->Promise.thenResolve(Operation.decodeJsonArray)
  ->Promise.thenResolve(ops =>
    ops->Belt.Array.keep(op => {
      op.kind == "transaction" && !Js.Re.test_(%re("/^kt1/i"), op.destination)
    })
  )
}

external unsafeParseBlockJSON: Js_dict.t<Js.Json.t> => {"indexer_last_block": int} = "%identity"

let getIndexerLastBlock = () =>
  Fetch.fetch("https://ithacanet.umamiwallet.com/monitor/blocks")
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(json => unsafeParseBlockJSON(json)["indexer_last_block"])
