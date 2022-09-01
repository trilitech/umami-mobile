external unsafeParse: Js.Json.t => Token.JSON.t = "%identity"

exception TokensFetchFailure(string)

let getTokens = (~tz1: Pkh.t, ~isTestNet) => {
  let tzktHost = isTestNet ? Endpoints.tzkt.testNet : Endpoints.tzkt.mainNet
  Fetch.fetch(`https://${tzktHost}/v1/tokens/balances/?account=${tz1->Pkh.toString}`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeParse))
  ->Promise.thenResolve(Token.decodeJsonArray)
  ->Promise.thenResolve(arr => arr->Belt.Array.keep(Token.positiveBalance))
  ->Promise.catch(err => Promise.reject(TokensFetchFailure(err->Helpers.getMessage)))
}
