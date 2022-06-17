open Jest

open Token
open SendInputs

let tokens = [
  FA1({
    id: 3922,
    balance: 1000000,
    tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
    tokenId: "0",
    contract: "KT1UCPcXExqEYRnfoXWYvBkkn5uPjn8TBTEe",
  }),
  FA2(
    {
      id: 3934,
      balance: 201060,
      tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
      tokenId: "0",
      contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
    },
    {name: "Klondike2", symbol: "KL2", decimals: 5},
  ),
  FA2(
    {
      balance: 400000,
      contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
      id: 3935,
      tokenId: "1",
      tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
    },
    {
      decimals: 5,
      name: "Klondike3",
      symbol: "KL3",
    },
  ),
  NFT(
    {
      balance: 1,
      contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
      id: 40465,
      tokenId: "3",
      tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
    },
    {
      creators: ["George Goodwin (@omgidrawedit)"],
      description: "Tezzardz is a collection of 4,200 programmatically, randomly generated, snazzy little fukrs on the Tezos blockchain.",
      displayUri: "https://ipfs.io/ipfs/zdj7Wk92xWxpzGqT6sE4cx7umUyWaX2Ck8MrSEmPAR31sNWGz",
      name: "Tezzardz #10",
      symbol: "FKR",
      thumbnailUri: "https://ipfs.io/ipfs/zb2rhXWQ9X95yxQwusNjftDSWVQYbGjFFFFBjJKQZ8uCrNcvV",
    },
  ),
  NFT(
    {
      balance: 0,
      contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
      id: 42130,
      tokenId: "4",
      tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
    },
    {
      creators: ["George Goodwin (@omgidrawedit)"],
      description: "Tezzardz is a collection of 4,200 programmatically, randomly generated, snazzy little fukrs on the Tezos blockchain.",
      displayUri: "https://ipfs.io/ipfs/zdj7WaSoswEYY5hcis4i4ZLDXpsusu8FaJNf4LfYXDoviiRem",
      name: "Tezzardz #12",
      symbol: "FKR",
      thumbnailUri: "https://ipfs.io/ipfs/zb2rhbd5iDakMTQMUADUM2YdPecMzrENnMHKBosEWD9Zc4f8e",
    },
  ),
]

describe("CurrencyPicker logic", () => {
  open Expect

  test("tokensToSelectItems returns the list of token symbols, including FA.1 and tez", () => {
    let expected = [
      {
        "label": "FA1.2",
        "value": "FA1.2",
      },
      {
        "label": "KL2",
        "value": "KL2",
      },
      {
        "label": "KL3",
        "value": "KL3",
      },
      {
        "label": "tez",
        "value": "tez",
      },
    ]
    expect(tokens->tokensToSelectItems)->toEqual(expected)
  })

  test("symbolToCurrencyData returns the correct value (case tez)", () => {
    let expected: option<SendTypes.currency> = CurrencyTez->Some

    expect("tez"->symbolToCurrencyData(tokens))->toEqual(expected)
  })

  test("symbolToCurrencyData returns the correct value (case fa2 token)", () => {
    let expected: option<SendTypes.currency> = CurrencyToken(
      {
        contract: "KT1XZoJ3PAidWVWRiKWESmPj64eKN7CEHuWZ",
        symbol: "KL3",
        tokenId: "1",
      },
      5,
    )->Some

    expect("KL3"->symbolToCurrencyData(tokens))->toEqual(expected)
  })

  test("symbolToCurrencyData returns the correct value (case fa1 token)", () => {
    let expected: option<SendTypes.currency> = CurrencyToken(
      {
        contract: "KT1UCPcXExqEYRnfoXWYvBkkn5uPjn8TBTEe",
        symbol: "FA1.2",
        tokenId: "0",
      },
      4,
    )->Some

    expect("FA1.2"->symbolToCurrencyData(tokens))->toEqual(expected)
  })
})
