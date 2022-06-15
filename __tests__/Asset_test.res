open Jest

open Asset
open Expect
open! Expect.Operators

external makeMockTokenBase: 'a => Token.tokenBase = "%identity"
external makeMockNFTMeta: 'a => Token.nftMetadata = "%identity"
external makeMockFA2Meta: 'a => Token.fa2TokenMetadata = "%identity"

describe("Asset", () => {
  test("updateAmount (Tez)", () => {
    let result = Tez(1)->updateAmount(3.21)
    expect(result)->toEqual(Tez(3210000))
  })

  test("updateAmount (FA1)", () => {
    let mockFa1 = FA1(makeMockTokenBase({"balance": 3000}))->Token

    let result = mockFa1->updateAmount(8.1)
    let expected = FA1(makeMockTokenBase({"balance": 81000}))->Token
    expect(result)->toEqual(expected)
  })

  test("updateAmount (FA2 ajusts value againts decimals in meta)", () => {
    let mockFa1 =
      FA2(makeMockTokenBase({"balance": 10000}), makeMockFA2Meta({"decimals": 7}))->Token

    let result = mockFa1->updateAmount(5.123)
    let expected =
      FA2(makeMockTokenBase({"balance": 51230000}), makeMockFA2Meta({"decimals": 7}))->Token
    expect(result)->toEqual(expected)
  })

  test("updateAmount (NFT has unchanged amount)", () => {
    let mockFa1 = NFT(makeMockTokenBase({"balance": 2}), makeMockNFTMeta(""))->Token

    let result = mockFa1->updateAmount(5.)
    let expected = NFT(makeMockTokenBase({"balance": 5}), makeMockNFTMeta(""))->Token
    expect(result)->toEqual(expected)
  })
})
