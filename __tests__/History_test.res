open Jest
open Operation

describe("History functions", () => {
  open Expect
  let myTz1 = "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS"
  let otherTz1_1 = "tz1ABVk9dxDALJUp4w1UTnC41ssvRa7Q4XCD"
  let otherTz1_2 = "tz1EFVk9dxDALJUp4w1UTnC41ssvRa7Q4XGH"

  test("makeDisplayInfo returns the right value", () => {
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
        amount: FA2({amount: 1, tokenId: "5", contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob"}),
        kind: "transaction",
        blockHash: Some("blockHash2"),
      },
      {
        hash: "hash4",
        src: myTz1,
        destination: otherTz1_2,
        level: 105,
        timestamp: "2022-05-25T17:07:20Z",
        amount: FA2({
          amount: 1000000,
          tokenId: "0",
          contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
        }),
        kind: "transaction",
        blockHash: Some("blockHash3"),
      },
    ]

    let result =
      input
      ->Belt.Array.map(op => OperationsScreen.makeDisplayElement(op, myTz1, 117))
      ->Helpers.filterNone
    expect(result)->toEqual([
      {
        target: "tz1AB...Q4XCD",
        date: "25/05/202212:34:18",
        prettyAmountDisplay: "-100 tez",
        hash: "hash1",
        status: Mempool,
      },
      {
        target: "tz1EF...Q4XGH",
        date: "25/05/202212:34:18",
        prettyAmountDisplay: "+100 tez",
        hash: "hash2",
        status: Processing,
      },
      {
        target: "tz1AB...Q4XCD",
        date: "18/05/202210:35:35",
        prettyAmountDisplay: "-1 token",
        hash: "hash3",
        status: Done,
      },
      {
        target: "tz1EF...Q4XGH",
        date: "25/05/202219:07:20",
        prettyAmountDisplay: "-1 token",
        hash: "hash4",
        status: Done,
      },
    ])
  })
})
