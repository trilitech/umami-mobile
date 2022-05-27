open Jest
open Operation

describe("Transaction functions", () => {
  open Expect

  test("decodeJSON returns the right value", () => {
    let jsonArray = parseJSON(`
    [
  {
    "hash": "op4LvXr33jDwo1bBFXpv3UJqQsohKR6JvLW2Y6xq6LmgX3yAchY",
    "id": "0",
    "block_hash": null,
    "op_timestamp": "2022-05-25T10:34:18Z",
    "level": "586915",
    "kind": "transaction",
    "src": "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
    "status": "applied",
    "fee": "445",
    "data": {
      "amount": "100000000",
      "token": "tez",
      "destination": "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
      "contract": null,
      "parameters": null,
      "entrypoint": null,
      "storage_size": null,
      "paid_storage_size_diff": null
    },
    "counter": "10315981",
    "gas_limit": "1521",
    "storage_limit": "0"
  },
   {
    "hash": "oniXhaqU7eev5P3sJm6FyvcS72VQDkPV7x23qpqr4s9aGDA2ZuQ",
    "id": "0",
    "block_hash": "mockBlockHash1",
    "op_timestamp": "2022-05-18T08:35:35Z",
    "level": "549850",
    "internal": 0,
    "kind": "transaction",
    "src": "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
    "status": "applied",
    "fee": "1229",
    "data": {
      "amount": "0",
      "token_amount": "1",
      "token": "fa2",
      "destination": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
      "contract": "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
      "parameters": null,
      "entrypoint": null,
      "storage_size": null,
      "paid_storage_size_diff": null,
      "token_id": "5",
      "internal_op_id": 0
    },
    "counter": "10315978",
    "gas_limit": "67",
    "storage_limit": "8233"
  },
    {
    "hash": "opSLAFTwZj25fZ79uJQrJicea2ZVWHQyRhhRPHidifytRBj4V2d",
    "id": "0",
    "block_hash": "mockBlockHash2",
    "op_timestamp": "2022-05-25T17:07:20Z",
    "level": "588389",
    "internal": 0,
    "kind": "transaction",
    "src": "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
    "status": "applied",
    "fee": "808",
    "data": {
      "amount": "0",
      "token_amount": "1000000",
      "token": "fa2",
      "destination": "tz1g2iHDjnB6HeNkbmAt7B73AYhKgtuhSa7t",
      "contract": "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
      "parameters": null,
      "entrypoint": null,
      "storage_size": null,
      "paid_storage_size_diff": null,
      "token_id": "0",
      "internal_op_id": 0
    },
    "counter": "10315995",
    "gas_limit": "69",
    "storage_limit": "4009"
  }
  
  ]
    `)
    let result = decodeJsonArray(jsonArray)
    expect(result)->toEqual([
      {
        hash: "op4LvXr33jDwo1bBFXpv3UJqQsohKR6JvLW2Y6xq6LmgX3yAchY",
        src: "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
        destination: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
        level: 586915,
        timestamp: "2022-05-25T10:34:18Z",
        amount: Tez(100000000),
        kind: "transaction",
        blockHash: None,
      },
      {
        hash: "oniXhaqU7eev5P3sJm6FyvcS72VQDkPV7x23qpqr4s9aGDA2ZuQ",
        src: "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
        destination: "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
        level: 549850,
        timestamp: "2022-05-18T08:35:35Z",
        amount: FA2({amount: 1, tokenId: "5", contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob"}),
        kind: "transaction",
        blockHash: Some("mockBlockHash1"),
      },
      {
        hash: "opSLAFTwZj25fZ79uJQrJicea2ZVWHQyRhhRPHidifytRBj4V2d",
        src: "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
        destination: "tz1g2iHDjnB6HeNkbmAt7B73AYhKgtuhSa7t",
        level: 588389,
        timestamp: "2022-05-25T17:07:20Z",
        amount: FA2({
          amount: 1000000,
          tokenId: "0",
          contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
        }),
        kind: "transaction",
        blockHash: Some("mockBlockHash2"),
      },
    ])
  })
})
