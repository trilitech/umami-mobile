open Jest

open PureAccountUtils

@send external call: ((. 'a) => 'b, 'c, 'a) => 'b = "call"
let call = (self, arg) => call(self, (), arg)

describe("PureAccountUtils", () => {
  testAsync("restore function scans accounts and returns associated keys", finish => {
    let mockFn = JestJs.fn(() => true->Promise.resolve)
    let fn = MockJs.fn(mockFn)

    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => true->Promise.resolve)->ignore
    mockFn->MockJs.mockImplementationOnce(() => false->Promise.resolve)->ignore

    let mockCheckExists = (tz1: string) => {
      Js.Console.log(tz1)
      fn()
    }

    let mockGenerateKeys = (~mnemonic as _, ~passphrase as _, ~derivationPathIndex=0, ()) =>
      Promise.resolve({
        derivationPathIndex: derivationPathIndex,
        pk: "mockPk",
        sk: "mockSk",
        tz1: "mockTz1",
      })

    module AccountUtils = Make({
      let generateKeys = mockGenerateKeys
      let checkExists = mockCheckExists
    })
    // expect(true)->toEqual(true)
    let expected = [
      {
        derivationPathIndex: 0,
        pk: "mockPk",
        sk: "mockSk",
        tz1: "mockTz1",
      },
      {
        derivationPathIndex: 1,
        pk: "mockPk",
        sk: "mockSk",
        tz1: "mockTz1",
      },
      {
        derivationPathIndex: 2,
        pk: "mockPk",
        sk: "mockSk",
        tz1: "mockTz1",
      },
    ]
    let mockMnemonic =
      "foo foo foo foo foo foo foo foo foo foo foo foo" ++ " foo foo foo foo foo foo foo foo foo foo foo foo"

    AccountUtils.restore(~mnemonic=mockMnemonic, ~passphrase="mockPass")
    ->Promise.thenResolve(result =>
      if result == expected {
        finish(pass)
      }
    )
    ->ignore
  })
})
