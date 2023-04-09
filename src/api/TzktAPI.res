external unsafeParse: Js.Json.t => Token.JSON.t = "%identity"

exception TokensFetchFailure(string)

// Memoize getMetaddata as it is exepensive
module MemoizedGetMetadata = {
  type metadataArgs = {
    network: Network.t,
    contractAddress: string,
    nodeIndex: int,
    tokenId: string,
  }

  let fn = (args: metadataArgs) => {
    TaquitoUtils.getMetadata(
      ~network=args.network,
      ~contractAddress=args.contractAddress,
      ~nodeIndex=args.nodeIndex,
      ~tokenId=args.tokenId,
    )
  }

  let serializeArgs = (args: metadataArgs) =>
    args.network->Network.toString ++
    args.contractAddress ++
    args.nodeIndex->Belt.Int.toString ++
    args.tokenId

  let getMetadata = fn->Cache.withCache(serializeArgs)
}

let getTokens = (~tz1: Pkh.t, ~network: Network.t, ~nodeIndex: int) => {
  let tzktHost = Endpoints.getTzktUrl(network)

  let getMetadata = (~tokenId, ~contractAddress) =>
    MemoizedGetMetadata.getMetadata({
      network: network,
      contractAddress: contractAddress,
      nodeIndex: nodeIndex,
      tokenId: tokenId,
    })

  Fetch.fetch(`https://api.${tzktHost}/v1/tokens/balances/?account=${tz1->Pkh.toString}`)
  ->Promise.then(Fetch.Response.json)
  ->Promise.thenResolve(Js.Json.decodeArray)
  ->Promise.thenResolve(Belt.Option.getExn)
  ->Promise.then(arr =>
    arr
    ->Belt.Array.map(el =>
      el->unsafeParse->Token.decodeJSON->Belt.Option.map(Token.addMetadata(~getMetadata))
    )
    ->Helpers.filterNone
    ->Promise.all
    ->Promise.thenResolve(arr => arr->Belt.Array.keep(Token.positiveBalance))
    ->Promise.catch(err => Promise.reject(TokensFetchFailure(err->Helpers.getMessage)))
  )
}

let getNft = (~tz1: Pkh.t, ~network: Network.t, ~nftInfo: Token.nftInfo, ~nodeIndex) => {
  getTokens(~tz1, ~network, ~nodeIndex)->Promise.thenResolve(tokens =>
    tokens
    ->Token.filterNFTs
    ->Belt.Array.getBy(((b, _)) =>
      b.contract == nftInfo.contract && b.balance == nftInfo.balance && b.tokenId == nftInfo.tokenId
    )
  )
}


%%private(
  let checkExists = (~tz1, ~network) => {
    let host = Endpoints.getTzktUrl(network)

    Fetch.fetch(`https://api.${host}/v1/accounts/${tz1->Pkh.toString}`)
    ->Promise.then(Fetch.Response.json)
    ->Promise.thenResolve(Js.Json.decodeObject)
    ->Promise.thenResolve(Belt.Option.getExn)
    ->Promise.thenResolve(obj => Js.Dict.unsafeGet(obj, "type"))
    ->Promise.thenResolve(Js.Json.decodeString)
    ->Promise.thenResolve(Belt.Option.getExn)
    ->Promise.thenResolve(address_type => address_type != "empty")
  }
)

open Network
let checkExistsAllNetworks = (~tz1) => {
  Promise.all2((
    checkExists(~tz1, ~network=Mainnet),
    checkExists(~tz1, ~network=Ghostnet),
  ))->Promise.thenResolve(((existsInTestNet, existsInMainNet)) =>
    existsInTestNet || existsInMainNet
  )
}
