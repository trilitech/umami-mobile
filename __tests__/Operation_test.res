open Jest
open Operation

@scope("JSON") @val
external parseTezJSON: string => array<JSON.Tez.t> = "parse"

@scope("JSON") @val
external parseTokenJSON: string => array<JSON.Token.t> = "parse"

describe("Operation functions", () => {
  open Expect

  test("parseTezTransactionJSON can parse transactions", () => {
    let result =
      OperationJSON.tezTransactionsRaw
      ->parseTezJSON
      ->Belt.Array.map(Operation.parseTezTransactionJSON)

    expect(result)->toEqual([
      {
        hash: Some("ooVDmsrcnqjBYVfYxSujpcZBMCqhwoHNr4xoh4Le4McbdSnhk3m"),
        src: "tz1SgK78wg4ug6Y6P5R2DH5j8BAeVMfHcNaC"->Pkh.unsafeBuild,
        destination: "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"->Pkh.unsafeBuild,
        level: 3340021,
        timestamp: "2023-04-11T07:13:43Z",
        amount: Tez(1398580),
        kind: "transaction",
        blockHash: Some("BLMF3QfBipTiZg4D8o7q35Rz4mZ1cG2wNKeqcrKN38dTVx2ktTJ"),
      },
      {
        hash: Some("oooRbGcps3F7zv3gcvo52EYPuboX2N4wNV7if1adTcxFi38Tr83"),
        src: "tz1VreUox3xqG7o5xbU1U69APw1hj1Y4xKCt"->Pkh.unsafeBuild,
        destination: "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"->Pkh.unsafeBuild,
        level: 3339993,
        timestamp: "2023-04-11T07:06:20Z",
        amount: Tez(414528974),
        kind: "transaction",
        blockHash: Some("BM3LUdjsTMw6mt9upGf4nFHg1KNk1VHPRjmXeTKJ5tnyeMoKgqx"),
      },
      {
        hash: Some("ontw4Sb7ikohCUDcYhHfY8fuBCA9oExjDSRdT2w4JrnBZRzpBxc"),
        src: "tz1PwVFw6GjLyVmz3uM3tthLRmQZf6xZiH93"->Pkh.unsafeBuild,
        destination: "tz1beW9AVJjE9QpTGYVPdtZCF5w1NPknMJ3T"->Pkh.unsafeBuild,
        level: 3339992,
        timestamp: "2023-04-11T07:06:05Z",
        amount: Tez(75997159),
        kind: "transaction",
        blockHash: Some("BM1XRWJB9nD1kgJa4SvtZWfTFGYdGbCrpZzncYd9BETkMBBPTgf"),
      },
    ])
  })

  test("parseTokenTransactionJSON can parse transactions", () => {
    let result =
      OperationJSON.tokenTransactionsRaw
      ->parseTokenJSON
      ->Belt.Array.map(Operation.parseTokenTransactionJSON)
    expect(result)->toEqual([
      {
        hash: None,
        src: "KT1BRADdqGk2eLmMqvyWzqVmPQ1RCBCbW5dY"->Pkh.unsafeBuild,
        destination: "tz2P2UEjxQLWHvasvf2rR5LT8kbDgHJcxPqg"->Pkh.unsafeBuild,
        level: 3194247,
        timestamp: "2023-03-03T16:43:14Z",
        amount: Contract({
          tokenId: "1",
          amount: 1,
          contract: "KT1BRADdqGk2eLmMqvyWzqVmPQ1RCBCbW5dY"
        }),
        kind: "transaction",
        blockHash: None,
      },
    ])
  })
})
