open Belt
let query = (domain: string) =>
  `
  query getAddres {
    domain(name:"${domain}") {
      name
      address
	  owner
   }
  }
`

let getDomainByAddress = (address: string) =>
  `
  query getDomainByAddress {
  reverseRecord(address:"${address}") {
    domain {
        name
        address
    
    }

	}
}
`

let graphqlEndpoint = "https://api.tezos.domains/graphql"

type tzDomain = {
  name: string,
  address: Js.Nullable.t<string>,
}

external parseAddress: Js_dict.t<Js.Json.t> => {"data": {"domain": Js.Nullable.t<tzDomain>}} =
  "%identity"

let getAddress = (domain: string) => {
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "query", Js.Json.string(query(domain)))
  Fetch.fetchWithInit(
    graphqlEndpoint,
    Fetch.RequestInit.make(
      ~method_=Post,
      ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
      ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
      (),
    ),
  )
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(parseAddress)
  ->Promise.thenResolve(d => d["data"]["domain"]->Js.Nullable.toOption)
  ->Promise.thenResolve(res =>
    res->Option.flatMap(res => res.address->Js.Nullable.toOption->Option.flatMap(Pkh.buildOption))
  )
}

type reverseRecord = {
  name: string,
  address: string,
}

external parseReverse: Js_dict.t<Js.Json.t> => {
  "data": {"reverseRecord": Js.Nullable.t<{"domain": reverseRecord}>},
} = "%identity"

let getDomain = (address: string) => {
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "query", Js.Json.string(getDomainByAddress(address)))
  Fetch.fetchWithInit(
    graphqlEndpoint,
    Fetch.RequestInit.make(
      ~method_=Post,
      ~body=Fetch.BodyInit.make(Js.Json.stringify(Js.Json.object_(payload))),
      ~headers=Fetch.HeadersInit.make({"Content-Type": "application/json"}),
      (),
    ),
  )
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeObject)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.thenResolve(parseReverse)
  ->Promise.thenResolve(d => d["data"]["reverseRecord"])
  ->Promise.thenResolve(d => Js.Nullable.toOption(d)->Option.map(res => res["domain"].name))
}

let isTezosDomain = (str: string) => Js.Re.test_(%re("/^\S+\.tez$/"), str)
