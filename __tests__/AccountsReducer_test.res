open Jest

describe("Accounts Reducer", () => {
  open Expect
  test("Reset", () => {
    let accounts = [
      Account.make(
        ~tz1="foo0"->Pkh.unsafeBuild,
        ~pk="bar0"->Pk.unsafeBuild,
        ~sk="cool0",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo1"->Pkh.unsafeBuild,
        ~pk="bar1"->Pk.unsafeBuild,
        ~sk="cool1",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo2"->Pkh.unsafeBuild,
        ~pk="bar2"->Pk.unsafeBuild,
        ~sk="cool2",
        ~derivationPathIndex=2,
        (),
      ),
      Account.make(
        ~tz1="foo3"->Pkh.unsafeBuild,
        ~pk="bar3"->Pk.unsafeBuild,
        ~sk="cool3",
        ~derivationPathIndex=3,
        (),
      ),
    ]

    let input = AccountsReducer.reducer(accounts, Reset)
    let expected = []
    expect(input)->toEqual(expected)
  })

  test("RenameAccount", () => {
    let accounts = [
      Account.make(
        ~tz1="foo0"->Pkh.unsafeBuild,
        ~pk="bar0"->Pk.unsafeBuild,
        ~sk="cool0",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo1"->Pkh.unsafeBuild,
        ~pk="bar1"->Pk.unsafeBuild,
        ~sk="cool1",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo2"->Pkh.unsafeBuild,
        ~pk="bar2"->Pk.unsafeBuild,
        ~sk="cool2",
        ~derivationPathIndex=2,
        (),
      ),
      Account.make(
        ~tz1="foo3"->Pkh.unsafeBuild,
        ~pk="bar3"->Pk.unsafeBuild,
        ~sk="cool3",
        ~derivationPathIndex=3,
        (),
      ),
    ]

    let input = AccountsReducer.reducer(
      accounts,
      RenameAccount({"tz1": "foo2"->Pkh.unsafeBuild, "name": "Bob"}),
    )
    let expected = [
      Account.make(
        ~tz1="foo0"->Pkh.unsafeBuild,
        ~pk="bar0"->Pk.unsafeBuild,
        ~sk="cool0",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo1"->Pkh.unsafeBuild,
        ~pk="bar1"->Pk.unsafeBuild,
        ~sk="cool1",
        ~derivationPathIndex=1,
        (),
      ),
      Account.make(
        ~tz1="foo2"->Pkh.unsafeBuild,
        ~pk="bar2"->Pk.unsafeBuild,
        ~sk="cool2",
        ~name="Bob",
        ~derivationPathIndex=2,
        (),
      ),
      Account.make(
        ~tz1="foo3"->Pkh.unsafeBuild,
        ~pk="bar3"->Pk.unsafeBuild,
        ~sk="cool3",
        ~derivationPathIndex=3,
        (),
      ),
    ]
    expect(input)->toEqual(expected)
  })
})
