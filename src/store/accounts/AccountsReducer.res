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

let updateAccountBalances = (accounts: array<Account.t>, updates: array<balancePayload>) => {
  accounts->Belt.Array.map(acc => {
    updates
    ->Belt.Array.getBy(u => u.tz1 == acc.tz1)
    ->Belt.Option.mapWithDefault(acc, u => {
      {...acc, balance: u.balance, tokens: u.tokens}
    })
  })
}

let updateAccountOperations = (accounts: array<Account.t>, updates: array<operationPayload>) => {
  accounts->Belt.Array.map(acc => {
    updates
    ->Belt.Array.getBy(u => u.tz1 == acc.tz1)
    ->Belt.Option.mapWithDefault(acc, u => {
      {...acc, transactions: u.operations}
    })
  })
}
type actions =
  | Add(array<Account.t>)
  | ReplaceAll(array<Account.t>)
  | Reset
  | UpdateBalances(array<balancePayload>)
  | UpdateOperations(array<operationPayload>)
  | RenameAccount({"name": string, "tz1": Pkh.t})
  | ResetAssets

let reducer = (accounts: array<Account.t>, action) => {
  switch action {
  | Reset => []
  | Add(newAccounts) => Array.concat(accounts, newAccounts)
  | ReplaceAll(newAccounts) => newAccounts
  | ResetAssets =>
    accounts->Array.map(account => {...account, balance: None, tokens: [], transactions: []})
  | RenameAccount(p) => {
      let indexToUpdate = accounts->Array.getIndexBy(a => a.tz1 == p["tz1"])
      let accountToUpdate = accounts->Array.getBy(a => a.tz1 == p["tz1"])

      Helpers.both(accountToUpdate, indexToUpdate)->Option.mapWithDefault(accounts, ((
        account,
        i,
      )) => accounts->Helpers.update(i, account->Account.changeName(p["name"])))
    }
  | UpdateBalances(b) => accounts->updateAccountBalances(b)
  | UpdateOperations(o) => accounts->updateAccountOperations(o)
  }
}

let useAccountsDispatcher = () => {
  let (accounts, setAccounts) = SavedStore.useAccounts()

  let fn = action => setAccounts(accounts => reducer(accounts, action))

  let dispatch = React.useMemo1(() => fn, [])
  (accounts, dispatch)
}
