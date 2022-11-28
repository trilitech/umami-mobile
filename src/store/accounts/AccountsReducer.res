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

let accountsReduxAtom: Jotai.Atom.t<
  array<Account.t>,
  Jotai.Atom.Actions.t<(unit => actions) => unit>,
  _,
> = Jotai.Atom.makeWritableComputed(
  ({get}) => {
    get(Atoms.accountsAtom)
  },
  ({get, set}, arg) => {
    let action = arg()

    if action == Reset {
      set(Atoms.selectedAccount, _ => 0)
    }

    let updated = Atoms.accountsAtom->get->reducer(action)

    Atoms.accountsAtom->set(updated)
  },
)

let useAccountsDispatcher = () => {
  let (accounts, set) = Jotai.Atom.use(accountsReduxAtom)
  (accounts, val => set(() => val))
}
