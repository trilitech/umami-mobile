open Belt
type balancePayload = {
  tz1: string,
  tokens: array<Token.t>,
  balance: option<int>,
}

type operationPayload = {
  tz1: string,
  operations: array<Operation.t>,
}

type actions =
  // | Reset
  // | AddAccounts(array<Account.t>)
  // | ReplaceAccounts(array<Account.t>)
  // | UpdateOperations({"tz1": string, "operations": array<Operation.t>})
  // | UpdateBalances(array<balancePayload>)
  // | RenameAccount({"name": string, "tz1": string})
  | ResetAssetInfos
// | AddAmounts

let reducer = (accounts: array<Account.t>, action) => {
  switch action {
  // | Reset => []
  // | AddAccounts(newAccounts) => Belt.Array.concat(accounts, newAccounts)
  // | ReplaceAccounts(newAccounts) => newAccounts
  | ResetAssetInfos =>
    accounts->Array.map(account => {...account, balance: None, tokens: [], transactions: []})
  // | UpdateBalances(balances) =>
  }
}

let useAccountsDispatcher = () => {
  let (_, setAccounts) = Store.useAccounts()

  let fn = action => setAccounts(accounts => reducer(accounts, action))

  let memoIniters = React.useMemo1(() => fn, [])
  memoIniters
}
