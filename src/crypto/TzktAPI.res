external unsafeParse: Js.Json.t => Token.JSON.t = "%identity"

let getTokens = tz1 => {
  Fetch.fetch("https://api.ithacanet.tzkt.io/v1/tokens/balances/?account=" ++ tz1)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeParse))
  ->Promise.thenResolve(Token.decodeJsonArray)
  ->Promise.thenResolve(arr => arr->Belt.Array.keep(Token.positiveBalance))
}
