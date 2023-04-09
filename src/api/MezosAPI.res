external unsafeToOperationJSON: Js.Json.t => Operation.JSON.t = "%identity"

exception MezosTransactionFetchFailure(string)

let makeHeaders = () =>
  DeviceId.id.contents->Belt.Option.mapWithDefault(Fetch.RequestInit.make(~method_=Get, ()), id => {
    let headers = Fetch.HeadersInit.make({
      "UmamiInstallationHash": ShortHash.unique(id),
    })
    Fetch.RequestInit.make(~method_=Get, ~headers, ())
  })

let getTransactions = (~tz1: Pkh.t, ~network) => {
  let url = Endpoints.getMezosUrl(network)
  Fetch.fetchWithInit(`https://${url}/accounts/${tz1->Pkh.toString}/operations`, makeHeaders())
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(Array.map(unsafeToOperationJSON))
  ->Promise.thenResolve(Operation.handleJSONArray)
  ->Promise.catch(err => Promise.reject(MezosTransactionFetchFailure(err->Helpers.getMessage)))
}
