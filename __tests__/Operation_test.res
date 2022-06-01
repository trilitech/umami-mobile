open Jest
open Operation

@scope("JSON") @val
external parseJSON: string => array<JSON.t> = "parse"

describe("Operation functions", () => {
  open Expect

  test("handleJSONarray returns the right value (nominal case TEZ + FA2)", () => {
    let input = parseJSON(`
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
    let result = handleJSONArray(input)
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
        amount: Contract({
          amount: 1,
          tokenId: "5"->Some,
          contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
        }),
        kind: "transaction",
        blockHash: Some("mockBlockHash1"),
      },
      {
        hash: "opSLAFTwZj25fZ79uJQrJicea2ZVWHQyRhhRPHidifytRBj4V2d",
        src: "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
        destination: "tz1g2iHDjnB6HeNkbmAt7B73AYhKgtuhSa7t",
        level: 588389,
        timestamp: "2022-05-25T17:07:20Z",
        amount: Contract({
          amount: 1000000,
          tokenId: "0"->Some,
          contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
        }),
        kind: "transaction",
        blockHash: Some("mockBlockHash2"),
      },
    ])
  })

  test("handleJSONarray returns the right value (nominal case FA1.2)", () => {
    let input = parseJSON(`
    [
        {
    "hash": "opUU1cokKoxbBQBJu6VsXR6g6CA66gnuUcvF7hGAYxwYGxPE8jZ",
    "id": "0",
    "block_hash": "BLXLjVGys2XWpzxGmguF4oVve9F43xthWiLu5R2RAcJ1UcAFsTk",
    "op_timestamp": "2022-06-01T13:14:35Z",
    "level": "624184",
    "internal": 0,
    "kind": "transaction",
    "src": "tz1UNer1ijeE9ndjzSszRduR3CzX49hoBUB3",
    "status": "applied",
    "fee": "792",
    "data": {
      "amount": "0",
      "token_amount": "100000",
      "token": "fa1-2",
      "destination": "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
      "contract": "KT1UCPcXExqEYRnfoXWYvBkkn5uPjn8TBTEe",
      "parameters": null,
      "entrypoint": null,
      "storage_size": null,
      "paid_storage_size_diff": null
    },
    "counter": "133965",
    "gas_limit": "0",
    "storage_limit": "3997"
  }
  ]
    `)
    let result = handleJSONArray(input)
    expect(result)->toEqual([
      {
        hash: "opUU1cokKoxbBQBJu6VsXR6g6CA66gnuUcvF7hGAYxwYGxPE8jZ",
        src: "tz1UNer1ijeE9ndjzSszRduR3CzX49hoBUB3",
        destination: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
        level: 624184,
        timestamp: "2022-06-01T13:14:35Z",
        amount: Contract({
          amount: 100000,
          tokenId: None,
          contract: "KT1UCPcXExqEYRnfoXWYvBkkn5uPjn8TBTEe",
        }),
        kind: "transaction",
        blockHash: Some("BLXLjVGys2XWpzxGmguF4oVve9F43xthWiLu5R2RAcJ1UcAFsTk"),
      },
    ])
  })

  test("handleJSONarray ignores transfers to kt1 and non transaction operations", () => {
    let input = parseJSON(`
    [
        {
    "hash": "opHFDksunqGYjTXbmcV9PnieDuTERnAtyN8cxK6TxfLq6agNktj",
    "id": "2",
    "block_hash": "BME3gJMJ8Ym5J87hJSxULuLqAiuc7auCwDKbFAF6a8JxEPoLPq4",
    "op_timestamp": "2022-04-26T18:13:55Z",
    "level": "445832",
    "internal": 0,
    "kind": "transaction",
    "src": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
    "status": "applied",
    "fee": "1228",
    "data": {
      "amount": "0",
      "token": "tez",
      "destination": "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
      "contract": null,
      "parameters": [
        {
          "prim": "Pair",
          "args": [
            {
              "string": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6"
            },
            [
              {
                "prim": "Pair",
                "args": [
                  {
                    "string": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6"
                  },
                  {
                    "prim": "Pair",
                    "args": [
                      {
                        "int": "1"
                      },
                      {
                        "int": "300000"
                      }
                    ]
                  }
                ]
              },
              {
                "prim": "Pair",
                "args": [
                  {
                    "string": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6"
                  },
                  {
                    "prim": "Pair",
                    "args": [
                      {
                        "int": "0"
                      },
                      {
                        "int": "100000"
                      }
                    ]
                  }
                ]
              }
            ]
          ]
        }
      ],
      "entrypoint": "transfer",
      "storage_size": null,
      "paid_storage_size_diff": null
    },
    "counter": "10303861",
    "gas_limit": "0",
    "storage_limit": "8561"
  },
        {
    "hash": "oofr3UjREFAAtmdKBACpybCjQ3dpRs17h8oWdcTwp2JyzFa3K6h",
    "id": "0",
    "block_hash": "BKmpLA7Z5YPfEgWVpSVE5q7YZ5mMkRDeD8ucFXSDz2wGf9xgJfy",
    "op_timestamp": "2022-04-26T18:29:35Z",
    "level": "445875",
    "internal": 0,
    "kind": "delegation",
    "src": "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
    "status": "applied",
    "fee": "397",
    "data": {
      "contract": null,
      "parameters": null,
      "entrypoint": null,
      "storage_size": null,
      "paid_storage_size_diff": null,
      "delegate": "tz1NiaviJwtMbpEcNqSP6neeoBYj8Brb3QPv"
    },
    "counter": "10303865",
    "gas_limit": "0",
    "storage_limit": "1100"
  },
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
    let result = handleJSONArray(input)
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
        amount: Contract({
          amount: 1,
          tokenId: "5"->Some,
          contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
        }),
        kind: "transaction",
        blockHash: Some("mockBlockHash1"),
      },
      {
        hash: "opSLAFTwZj25fZ79uJQrJicea2ZVWHQyRhhRPHidifytRBj4V2d",
        src: "tz1Pi78RgQvhvCGWuWVzbkEKvY9SF8pSn3x5",
        destination: "tz1g2iHDjnB6HeNkbmAt7B73AYhKgtuhSa7t",
        level: 588389,
        timestamp: "2022-05-25T17:07:20Z",
        amount: Contract({
          amount: 1000000,
          tokenId: "0"->Some,
          contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
        }),
        kind: "transaction",
        blockHash: Some("mockBlockHash2"),
      },
    ])
  })
})
