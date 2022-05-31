type balancePayload = {
  tz1: string,
  tokens: array<Token.allTokens>,
  balance: option<int>,
}

type operationPayload = {
  tz1: string,
  operations: array<Operation.t>,
}

type actions =
  | Reset
  | AddAccounts(array<Account.t>)
  | ReplaceAccounts(array<Account.t>)
  | UpdateOperations({"tz1": string, "operations": array<Operation.t>})
  | UpdateBalances(array<balancePayload>)
  | RenameAccount({"name": string, "tz1": string})
  | AddAmounts

let reducer = (accounts: array<Account.t>, action) => {
  switch action {
  | Reset => []
  | AddAccounts(newAccounts) => Belt.Array.concat(accounts, newAccounts)
  | ReplaceAccounts(newAccounts) => newAccounts
  // | UpdateBalances(balances) =>
  | _ => accounts
  }
}

let useAccountsActions = () => {
  let (_, setAccounts) = Store.useAccounts()

  action => setAccounts(accounts => reducer(accounts, action))
}
