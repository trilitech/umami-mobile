open Jest

describe("Accounts Reducer", () => {
  open Expect
  test("Reset", () => {
    let accounts = [
      Account.make(~tz1="foo0", ~pk="bar0", ~sk="cool0", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo1", ~pk="bar1", ~sk="cool1", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo2", ~pk="bar2", ~sk="cool2", ~derivationPathIndex=2, ()),
      Account.make(~tz1="foo3", ~pk="bar3", ~sk="cool3", ~derivationPathIndex=3, ()),
    ]

    let input = AccountsReducer.reducer(accounts, Reset)
    let expected = []
    expect(input)->toEqual(expected)
  })

  test("RenameAccount", () => {
    let accounts = [
      Account.make(~tz1="foo0", ~pk="bar0", ~sk="cool0", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo1", ~pk="bar1", ~sk="cool1", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo2", ~pk="bar2", ~sk="cool2", ~derivationPathIndex=2, ()),
      Account.make(~tz1="foo3", ~pk="bar3", ~sk="cool3", ~derivationPathIndex=3, ()),
    ]

    let input = AccountsReducer.reducer(accounts, RenameAccount({"tz1": "foo2", "name": "Bob"}))
    let expected = [
      Account.make(~tz1="foo0", ~pk="bar0", ~sk="cool0", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo1", ~pk="bar1", ~sk="cool1", ~derivationPathIndex=1, ()),
      Account.make(~tz1="foo2", ~pk="bar2", ~sk="cool2", ~name="Bob", ~derivationPathIndex=2, ()),
      Account.make(~tz1="foo3", ~pk="bar3", ~sk="cool3", ~derivationPathIndex=3, ()),
    ]
    expect(input)->toEqual(expected)
  })
})
