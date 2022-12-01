open Belt

type balancePayload = {
  tz1: Pkh.t,
  tokens: array<Token.t>,
  balance: option<int>,
}

type operationPayload = {
  tz1: Pkh.t,
  operations: array<Operation.t>,
}

type actions =
  | Add(array<Account.t>)
  | ReplaceAll(array<Account.t>)
  | Reset
  | RenameAccount({"name": string, "tz1": Pkh.t})

let reducer = (accounts: array<Account.t>, action) => {
  switch action {
  | Reset => []
  | Add(newAccounts) => Array.concat(accounts, newAccounts)
  | ReplaceAll(newAccounts) => newAccounts
  | RenameAccount(p) => {
      let indexToUpdate = accounts->Array.getIndexBy(a => a.tz1 == p["tz1"])
      let accountToUpdate = accounts->Array.getBy(a => a.tz1 == p["tz1"])

      Helpers.both(accountToUpdate, indexToUpdate)->Option.mapWithDefault(accounts, ((
        account,
        i,
      )) => accounts->Helpers.update(i, account->Account.changeName(p["name"])))
    }
  }
}
