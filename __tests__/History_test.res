open Jest

@scope("JSON") @val
external parseTokenJSON: string => array<Token.JSON.t> = "parse"

@scope("JSON") @val
external parseOperationJSON: string => array<Operation.JSON.t> = "parse"

describe("History functions", () => {
  open Expect
  let myTz1 = "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS"->Pkh.unsafeBuild

  test("makeDisplayInfo returns the right value", () => {
    let operations = OperationJSON.jsonString1->parseOperationJSON->Operation.handleJSONArray
    let tokens = TokenJSON.jsonString1->Token.jsonStringToTokens

    let result = OperationsScreen.makePrettyOperations(
      ~myTz1,
      ~operations,
      ~indexerLastBlock=100000000,
      ~tokens,
    )
    expect(result)->toEqual([
      {
        target: "tz1UNer1ijeE9ndjzSszRduR3CzX49hoBUB3"->Pkh.unsafeBuild,
        date: "01/06/2022 15:14:35",
        prettyAmountDisplay: CurrencyTrade("+10 KLD"),
        hash: "opUU1cokKoxbBQBJu6VsXR6g6CA66gnuUcvF7hGAYxwYGxPE8jZ",
        status: Done,
      },
      {
        target: "tz1UNer1ijeE9ndjzSszRduR3CzX49hoBUB3"->Pkh.unsafeBuild,
        date: "01/06/2022 15:13:20",
        prettyAmountDisplay: CurrencyTrade("+2 KL2"),
        hash: "onrvxGZ9iMqcCmQ1zG9ZTr3dDC5cqY3ADmg4PhWNN1ydFrdeYN5",
        status: Done,
      },
      {
        target: "tz1aWXP237BLwNHJcCD4b3DutCevhqq2T1Z9"->Pkh.unsafeBuild,
        date: "01/06/2022 08:05:15",
        prettyAmountDisplay: CurrencyTrade("+26.4249 tez"),
        hash: "opWYyTWguCwH8Ph1dNya5eTNfhBRKhZWo2aQCyh7vpN2jAZbX4y",
        status: Done,
      },
      {
        target: "tz1UNer1ijeE9ndjzSszRduR3CzX49hoBUB3"->Pkh.unsafeBuild,
        date: "01/06/2022 14:04:15",
        prettyAmountDisplay: NFTTrade(
          "+1",
          "https://ipfs.io/ipfs/zb2rhndGmg3GajqCvCwCr7ripVpxTYUfWNRJat6dsWhPSsvnu",
        ),
        hash: "ooHKBx5verQK5XcL6U8yJ8WrZJeLUwp7KqfaHkH9TVZxaxUVe9Q",
        status: Done,
      },
    ])
  })
  let myTz1 = "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS"->Pkh.unsafeBuild
  let otherTz1_1 = "tz1ABVk9dxDALJUp4w1UTnC41ssvRa7Q4XCD"->Pkh.unsafeBuild
  let otherTz1_2 = "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"->Pkh.unsafeBuild

  open Operation
  test(
    "makeDisplayInfo returns the right value (edge case with status against indexor leve)",
    () => {
      let input = [
        {
          hash: "hash1",
          src: myTz1,
          destination: otherTz1_1,
          level: 120,
          timestamp: "2022-05-25T10:34:18Z",
          amount: Tez(100000000),
          kind: "transaction",
          blockHash: None,
        },
        {
          hash: "hash2",
          src: otherTz1_2,
          destination: myTz1,
          level: 115,
          timestamp: "2022-05-25T10:34:18Z",
          amount: Tez(100000000),
          kind: "transaction",
          blockHash: Some("blockHash1"),
        },
        {
          hash: "hash3",
          src: myTz1,
          destination: otherTz1_1,
          level: 110,
          timestamp: "2022-05-18T08:35:35Z",
          amount: Contract({
            amount: 1,
            tokenId: Some("5"),
            contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
          }),
          kind: "transaction",
          blockHash: Some("blockHash2"),
        },
        {
          hash: "hash4",
          src: myTz1,
          destination: otherTz1_2,
          level: 105,
          timestamp: "2022-05-25T17:07:20Z",
          amount: Contract({
            amount: 1000000,
            tokenId: "0"->Some,
            contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
          }),
          kind: "transaction",
          blockHash: Some("blockHash3"),
        },
      ]
      let tokens = TokenJSON.jsonString1->Token.jsonStringToTokens

      let result =
        input
        ->Belt.Array.map(op => OperationsScreen.makeDisplayElement(op, myTz1, 117, tokens))
        ->Helpers.filterNone

      expect(result)->toEqual([
        {
          target: "tz1ABVk9dxDALJUp4w1UTnC41ssvRa7Q4XCD"->Pkh.unsafeBuild,
          date: "25/05/2022 12:34:18",
          prettyAmountDisplay: CurrencyTrade("-100 tez"),
          hash: "hash1",
          status: Mempool,
        },
        {
          target: "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"->Pkh.unsafeBuild,
          date: "25/05/2022 12:34:18",
          prettyAmountDisplay: CurrencyTrade("+100 tez"),
          hash: "hash2",
          status: Processing,
        },
        {
          target: "tz1ABVk9dxDALJUp4w1UTnC41ssvRa7Q4XCD"->Pkh.unsafeBuild,
          date: "18/05/2022 10:35:35",
          prettyAmountDisplay: NFTTrade(
            "-1",
            "https://ipfs.io/ipfs/zb2rhndGmg3GajqCvCwCr7ripVpxTYUfWNRJat6dsWhPSsvnu",
          ),
          hash: "hash3",
          status: Done,
        },
        {
          target: "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"->Pkh.unsafeBuild,
          date: "25/05/2022 19:07:20",
          prettyAmountDisplay: CurrencyTrade("-10 KL2"),
          hash: "hash4",
          status: Done,
        },
      ])
    },
  )

  test(
    "makeDisplayInfo returns the right value (edge case with 2 tokens that have same contract and different id)",
    () => {
      let input = [
        {
          hash: "hash3",
          src: myTz1,
          destination: otherTz1_2,
          level: 105,
          timestamp: "2022-05-24T17:07:20Z",
          amount: Contract({
            amount: 2000000,
            tokenId: "1"->Some,
            contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
          }),
          kind: "transaction",
          blockHash: Some("blockHash3"),
        },
        {
          hash: "hash4",
          src: myTz1,
          destination: otherTz1_2,
          level: 105,
          timestamp: "2022-05-25T17:07:20Z",
          amount: Contract({
            amount: 1000000,
            tokenId: "0"->Some,
            contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
          }),
          kind: "transaction",
          blockHash: Some("blockHash3"),
        },
      ]

      let tokens = TokenJSON.jsonString1->Token.jsonStringToTokens
      let result =
        input
        ->Belt.Array.map(op => OperationsScreen.makeDisplayElement(op, myTz1, 117, tokens))
        ->Helpers.filterNone

      expect(result)->toEqual([
        {
          target: "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"->Pkh.unsafeBuild,
          date: "24/05/2022 19:07:20",
          prettyAmountDisplay: CurrencyTrade("-20 KL3"),
          hash: "hash3",
          status: Done,
        },
        {
          target: "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"->Pkh.unsafeBuild,
          date: "25/05/2022 19:07:20",
          prettyAmountDisplay: CurrencyTrade("-10 KL2"),
          hash: "hash4",
          status: Done,
        },
      ])
    },
  )
})
