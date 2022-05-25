// bind to JS' JSON.parse

module JSON = {
  type amount = {
    amount: string,
    token_amount: string,
    token_id: string,
    token: string,
    destination: string,
    contract: Js.Nullable.t<string>,
  }

  type t = {
    src: string,
    amount: amount,
    hash: string,
    bloc_hash: string,
    op_timestamp: string,
    status: string,
    fee: string,
    gas_limit: string,
    storage_limit: string,
  }
}

@scope("JSON") @val
external parseJSON: string => array<JSON.t> = "parse"

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
