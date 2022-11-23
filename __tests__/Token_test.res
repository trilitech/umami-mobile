@scope("JSON") @val
open Jest
open Token

@scope("JSON") @val
external parseJSON: string => array<JSON.t> = "parse"

describe("Token functions", () => {
  open Expect

  test("handleJSONarray returns the right value (nominal case)", () => {
    let input = parseJSON(TokenJSON.jsonString1)
    let result = decodeJsonArray(input)
    expect(result)->toEqual([
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
      NFT(
        {
          balance: 0,
          contract: "KT1GVhG7dQNjPAt4FNBNmc9P9zpiQex4Mxob",
          id: 42145,
          tokenId: "5",
          tz1: "tz1g7Vk9dxDALJUp4w1UTnC41ssvRa7Q4XyS",
        },
        {
          creators: ["George Goodwin (@omgidrawedit)"],
          description: "Tezzardz is a collection of 4,200 programmatically, randomly generated, snazzy little fukrs on the Tezos blockchain.",
          displayUri: "https://ipfs.io/ipfs/zdj7WVwx4CX5fK5sHmXhjTm5wG9nCrzSBy83CGNXJ78fAJmba",
          name: "Tezzardz #20",
          symbol: "FKR",
          thumbnailUri: "https://ipfs.io/ipfs/zb2rhndGmg3GajqCvCwCr7ripVpxTYUfWNRJat6dsWhPSsvnu",
        },
      ),
    ])
  })

  test("handleJSONarray returns the right value (fix for bloxxer NFT bug)", () => {
    let input = parseJSON(TokenJSON.jsonStringBloxxer)
    let result = decodeJsonArray(input)
    expect(result)->toEqual([
      NFT(
        {
          balance: 1,
          contract: "KT1NjMYSVnfrTiuKEKsyXp61hnWP3CL6qPW2",
          id: %raw("387481387139073"), // TODO fix bigint rescript issue
          tokenId: "0",
          tz1: "tz1Te4MXuNYxyyuPqmAQdnKwkD8ZgSF9M7d6",
        },
        {
          creators: [],
          description: "This is a special pre-release beta cartridge of the Blockxer game, allowing players to try the game before it is launched.",
          displayUri: "https://ipfs.io/ipfs/QmVhgnkY9G6yT4BhHKbwQg9gyCzWF7fFeDM4YTyttXWJpt",
          name: "Blockxer Beta Cartridge",
          symbol: "FKR",
          thumbnailUri: "https://ipfs.io/ipfs/QmVhgnkY9G6yT4BhHKbwQg9gyCzWF7fFeDM4YTyttXWJpt",
        },
      ),
    ])
  })
})
