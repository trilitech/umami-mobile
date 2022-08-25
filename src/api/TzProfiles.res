let query = (tz1: string) =>
  `query MyQuery {
  tzprofiles_by_pk(account: "${tz1}") {
    description
    alias
    website
    twitter
    logo
  }
}
`

let graphqlEndpoint = "https://tzprofiles.dipdup.net/v1/graphql"

// type TzProfile = {
//   tzprofiles_by_pk: Js.Nullable.t
// }

type tzProfile = {
  alias: Js.Nullable.t<string>,
  logo: Js.Nullable.t<string>,
  twitter: Js.Nullable.t<string>,
  website: Js.Nullable.t<string>,
}

external parseTzProfile: Js_dict.t<Js.Json.t> => {
  "data": {"tzprofiles_by_pk": Js.Nullable.t<tzProfile>},
} = "%identity"

// let unsafeParse =

let getProfile = (tz1: string) => {
  let payload = Js.Dict.empty()
  Js.Dict.set(payload, "query", Js.Json.string(query(tz1)))
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
  ->Promise.thenResolve(parseTzProfile)
  ->Promise.thenResolve(d => d["data"]["tzprofiles_by_pk"]->Js.Nullable.toOption)
}
