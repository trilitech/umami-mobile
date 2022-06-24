open UsePrevious

let getAccountBalance = (~tz1: string, ~isTestNet) => {
  open AccountsReducer
  Promise.all2((
    TaquitoUtils.getBalance(~tz1, ~isTestNet),
    TzktAPI.getTokens(~tz1, ~isTestNet),
  ))->Promise.thenResolve(((b, t)) => {
    {tz1: tz1, balance: Some(b), tokens: t}
  })
}

let getAccountOperations = (tz1: string, ~isTestNet) => {
  open AccountsReducer
  MezosAPI.getTransactions(~tz1, ~isTestNet)->Promise.thenResolve(operations => {
    {tz1: tz1, operations: operations}
  })
}

let updateAccountBalances = (
  accounts: array<Account.t>,
  updates: array<AccountsReducer.balancePayload>,
) => {
  accounts->Belt.Array.map(acc => {
    updates
    ->Belt.Array.getBy(u => u.tz1 == acc.tz1)
    ->Belt.Option.mapWithDefault(acc, u => {
      {...acc, balance: u.balance, tokens: u.tokens}
    })
  })
}

let updateAccountOperations = (
  accounts: array<Account.t>,
  updates: array<AccountsReducer.operationPayload>,
) => {
  accounts->Belt.Array.map(acc => {
    updates
    ->Belt.Array.getBy(u => u.tz1 == acc.tz1)
    ->Belt.Option.mapWithDefault(acc, u => {
      {...acc, transactions: u.operations}
    })
  })
}

open Account

let getBalances = (~accounts, ~isTestNet) =>
  accounts->Belt.Array.map(a => getAccountBalance(~tz1=a.tz1, ~isTestNet))->Js.Promise.all

let getOperations = (~accounts, ~isTestNet) =>
  accounts->Belt.Array.map(a => getAccountOperations(a.tz1, ~isTestNet))->Js.Promise.all

let useTransactionNotif = () => {
  let (accounts, _) = Store.useAccounts()

  let prevAccounts = usePrevious(accounts)
  let notify = SnackBar.useNotification()

  React.useEffect3(() => {
    prevAccounts
    ->Belt.Option.map(prevAccounts => {
      TransNotif.getUpdates(prevAccounts, accounts)->Belt.Array.forEach(notification => {
        open TezHelpers
        notify(`${notification.name} received ${notification.amount->formatBalance}`)
      })
    })
    ->ignore

    None
  }, (accounts, notify, prevAccounts))
}

open Helpers

let _parseError = (e: exn) => {
  open MezosAPI
  open TzktAPI
  open TaquitoUtils
  switch e {
  | MezosLastBlockFetchFailure(m) => "Failed to fetch last block. Reason: " ++ m
  | MezosTransactionFetchFailure(m) => "Failed to fetch operations. Reason: " ++ m
  | BalanceFetchFailure(m) => "Failed to fetch balances. Reason: " ++ m
  | TokensFetchFailure(m) => "Failed to fetch tokens. Reason: " ++ m
  | _ => Helpers.getMessage(e)
  }
}

let _handleError = (notify, e) => {
  e->_parseError->notify
  Promise.reject(e)
}

let useBalancesSync = () => {
  let isTestNet = Store.useIsTestNet()
  let (accounts, setAccounts) = SavedStore.useAccounts()
  let notify = SnackBar.useNotification()

  let isTestNetRef = React.useRef(isTestNet)
  let accountsRef = React.useRef(accounts)

  isTestNetRef.current = isTestNet
  accountsRef.current = accounts

  let update = () => {
    let accounts = accountsRef.current
    let isTestNet = isTestNetRef.current

    let operationsPromise =
      getOperations(~isTestNet, ~accounts)
      ->Promise.thenResolve(o => setAccounts(a => a->updateAccountOperations(o)))
      ->Promise.catch(_handleError(notify))

    let balancesPromise =
      getBalances(~isTestNet, ~accounts)
      ->Promise.thenResolve(b => setAccounts(a => a->updateAccountBalances(b)))
      ->Promise.catch(_handleError(notify))

    Promise.all2((balancesPromise, operationsPromise))
  }

  let updateRef = React.useRef(update)

  let (_, stop, refresh) = React.useMemo1(
    () => makeQueryAutomator(~fn=() => updateRef.current(), ()),
    [],
  )

  React.useEffect2(() => {
    refresh()
    None
  }, (isTestNet, refresh))

  React.useEffect1(() => Some(stop), [])
}
