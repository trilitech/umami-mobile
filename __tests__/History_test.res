open Jest

@scope("JSON") @val
external parseTokenJSON: string => array<Token.JSON.t> = "parse"

@scope("JSON") @val
external parseOperationJSON: string => array<Operation.JSON.t> = "parse"

describe("History functions", () => {
  open Expect
  let myTz1 = "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS"

  test("makeDisplayInfo returns the right value", () => {
    let operations = OperationJSON.jsonString1->parseOperationJSON->Operation.handleJSONArray
    let tokens = TokenJSON.jsonString1->parseTokenJSON->Token.decodeJsonArray

    let result = OperationsScreen.makePrettyOperations(
      ~myTz1,
      ~operations,
      ~indexerLastBlock=100000000,
      ~tokens,
    )
    expect(result)->toEqual([
      {
        target: "tz1UN...oBUB3",
        date: "01/06/2022 15:14:35",
        prettyAmountDisplay: Currency("+10 KLD"),
        hash: "opUU1cokKoxbBQBJu6VsXR6g6CA66gnuUcvF7hGAYxwYGxPE8jZ",
        status: Done,
      },
      {
        target: "tz1UN...oBUB3",
        date: "01/06/2022 15:13:20",
        prettyAmountDisplay: Currency("+2 KL2"),
        hash: "onrvxGZ9iMqcCmQ1zG9ZTr3dDC5cqY3ADmg4PhWNN1ydFrdeYN5",
        status: Done,
      },
      {
        target: "tz1aW...2T1Z9",
        date: "01/06/2022 08:05:15",
        prettyAmountDisplay: Currency("+26 tez"),
        hash: "opWYyTWguCwH8Ph1dNya5eTNfhBRKhZWo2aQCyh7vpN2jAZbX4y",
        status: Done,
      },
      {
        target: "tz1UN...oBUB3",
        date: "01/06/2022 14:04:15",
        prettyAmountDisplay: Currency("+1 FKR"),
        hash: "ooHKBx5verQK5XcL6U8yJ8WrZJeLUwp7KqfaHkH9TVZxaxUVe9Q",
        status: Done,
      },
    ])
  })
  let myTz1 = "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS"
  let otherTz1_1 = "tz1ABVk9dxDALJUp4w1UTnC41ssvRa7Q4XCD"
  let otherTz1_2 = "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"

  open Operation
  test(
    "makeDisplayInfo returns the right value (edge case with status agains indexor leve)",
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

      let result =
        input
        ->Belt.Array.map(op => OperationsScreen.makeDisplayElement(op, myTz1, 117, []))
        ->Helpers.filterNone
      expect(result)->toEqual([
        {
          target: "tz1AB...Q4XCD",
          date: "25/05/2022 12:34:18",
          prettyAmountDisplay: Currency("-100 tez"),
          hash: "hash1",
          status: Mempool,
        },
        {
          target: "tz1EF...Q4XGH",
          date: "25/05/2022 12:34:18",
          prettyAmountDisplay: Currency("+100 tez"),
          hash: "hash2",
          status: Processing,
        },
        {
          target: "tz1AB...Q4XCD",
          date: "18/05/2022 10:35:35",
          prettyAmountDisplay: Currency("-1 Token"),
          hash: "hash3",
          status: Done,
        },
        {
          target: "tz1EF...Q4XGH",
          date: "25/05/2022 19:07:20",
          prettyAmountDisplay: Currency("-1000000 Token"),
          hash: "hash4",
          status: Done,
        },
      ])
    },
  )
})
