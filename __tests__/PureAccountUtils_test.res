open Jest

open PureAccountUtils

@send external call: ((. 'a) => 'b, 'c, 'a) => 'b = "call"
let call = (self, arg) => call(self, (), arg)

describe("PureAccountUtils", () => {
  testAsync("restoreKeysPromise function scans accounts and returns associated keys", finish => {
    let mockFn = JestJs.fn(() => true->Promise.resolve)
    let fn = MockJs.fn(mockFn)

    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => false->Promise.resolve)->ignore

    let mockCheckExists = (~tz1 as _) => {
      fn()
    }

    let mockGenerateKeys = (~mnemonic as _, ~password as _, ~derivationPathIndex=0, ()) =>
      Promise.resolve({
        derivationPathIndex: derivationPathIndex,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      })

    module AccountUtils = Make({
      let generateKeys = mockGenerateKeys
      let checkExists = mockCheckExists
    })

    let expected = [
      {
        derivationPathIndex: 0,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      },
      {
        derivationPathIndex: 1,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      },
      {
        derivationPathIndex: 2,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      },
    ]
    let mockMnemonic =
      "foo foo foo foo foo foo foo foo foo foo foo foo" ++ " foo foo foo foo foo foo foo foo foo foo foo foo"

    AccountUtils.restoreKeysPromise(~mnemonic=mockMnemonic, ~password="mockPass")
    ->Promise.thenResolve(result =>
      if result == expected {
        finish(pass)
      }
    )
    ->ignore
  })

  testAsync("restoreKeysPromise returns first derivated account if it is not revealad", finish => {
    let mockFn = JestJs.fn(() => true->Promise.resolve)
    let fn = MockJs.fn(mockFn)

    mockFn->MockJs.mockImplementationOnce(() => false->Promise.resolve)->ignore

    let mockCheckExists = (~tz1 as _) => {
      fn()
    }

    let mockGenerateKeys = (~mnemonic as _, ~password as _, ~derivationPathIndex=0, ()) =>
      Promise.resolve({
        derivationPathIndex: derivationPathIndex,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      })

    module AccountUtils = Make({
      let generateKeys = mockGenerateKeys
      let checkExists = mockCheckExists
    })

    let expected = [
      {
        derivationPathIndex: 0,
        pk: "mockPk"->Pk.unsafeBuild,
        sk: "mockSk",
        tz1: "mockTz1"->Pkh.unsafeBuild,
      },
    ]
    let mockMnemonic =
      "foo foo foo foo foo foo foo foo foo foo foo foo" ++ " foo foo foo foo foo foo foo foo foo foo foo foo"

    AccountUtils.restoreKeysPromise(~mnemonic=mockMnemonic, ~password="mockPass")
    ->Promise.thenResolve(result => {
      if result == expected {
        finish(pass)
      }
    })
    ->ignore
  })
})
