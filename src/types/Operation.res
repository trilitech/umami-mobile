open Belt
type contractData = {
  amount: int,
  tokenId: option<string>,
  contract: string,
}

type amount = Tez(int) | Contract(contractData)

type t = {
  src: Pkh.t,
  hash: string,
  destination: Pkh.t,
  level: int,
  timestamp: string,
  amount: amount,
  kind: string,
  blockHash: option<string>,
}

module JSON = {
  type data = {
    amount: string,
    token: string,
    token_amount: option<string>,
    token_id: option<string>, // on mezos, fa1.2 tokens have no tokenId
    contract: Js.Nullable.t<string>,
    destination: string,
  }

  type t = {
    src: string,
    data: data,
    hash: string,
    status: string,
    level: string,
    block_hash: Js.Nullable.t<string>,
    op_timestamp: string,
    fee: string,
    gas_limit: string,
    storage_limit: string,
    kind: string,
  }
}

// {
//     "hash": "oniXhaqU7eev5P3sJm6FyvcS72VQDkPV7x23qpqr4s9aGDA2ZuQ",
//     "id": "0",
//     "block_hash": "BL1p6asvJSc24aqNNf2azcJ8VcukJFC6s1T7JSs3RGpf2EKF3Rv",
//     "op_timestamp": "2022-05-18T08:35:35Z",
//     "level": "549850",
//     "internal": 0,
//     "kind": "transaction",
//     "src": "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
//     "status": "applied",
//     "fee": "1229",
//     "data": {
//       "amount": "0",
//       "token_amount": "1",
//       "token": "fa2",
//       "destination": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
//       "contract": "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
//       "parameters": null,
//       "entrypoint": null,
//       "storage_size": null,
//       "paid_storage_size_diff": null,
//       "token_id": "5",
//       "internal_op_id": 0
//     },
//     "counter": "10315978",
//     "gas_limit": "67",
//     "storage_limit": "8233"
//   }

let decodeDataField = (data: JSON.data) => {
  switch data.token {
  | "tez" => Belt.Int.fromString(data.amount)->Option.map(amount => Tez(amount))
  | "fa1-2" =>
    switch (data.token_amount, data.token_id, data.contract->Js.Nullable.toOption) {
    | (Some(tokenAmount), None, Some(contract)) =>
      Belt.Int.fromString(tokenAmount)->Option.map(amount => Contract({
        amount: amount,
        tokenId: None,
        contract: contract,
      }))
    | _ => None
    }
  | "fa2" =>
    switch (data.token_amount, data.token_id, data.contract->Js.Nullable.toOption) {
    | (Some(tokenAmount), Some(tokenId), Some(contract)) =>
      Belt.Int.fromString(tokenAmount)->Option.map(amount => Contract({
        amount: amount,
        tokenId: tokenId->Some,
        contract: contract,
      }))
    | _ => None
    }
  | _ => None
  }
}

let decodeJson = (json: JSON.t) => {
  json.data
  ->decodeDataField
  ->Option.flatMap(amount =>
    Helpers.three(
      Belt.Int.fromString(json.level),
      json.src->Pkh.buildOption,
      json.data.destination->Pkh.buildOption,
    )->Option.map(((level, src, destination)) => {
      src: src,
      destination: destination,
      level: level,
      timestamp: json.op_timestamp,
      amount: amount,
      kind: json.kind,
      hash: json.hash,
      blockHash: json.block_hash->Js.Nullable.toOption,
    })
  )
}

let decodeJsonArray = arr => arr->Belt.Array.map(decodeJson)->Helpers.filterNone

let keepRelevant = ops =>
  ops->Belt.Array.keep(op => op.kind == "transaction" && op.destination->Pkh.notKt)

let handleJSONArray = arr => arr->decodeJsonArray->keepRelevant
