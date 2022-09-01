open UsePrevious

let getAccountBalance = (~tz1: Pkh.t, ~isTestNet) => {
  open AccountsReducer
  Promise.all2((
    TaquitoUtils.getBalance(~tz1, ~isTestNet),
    TzktAPI.getTokens(~tz1, ~isTestNet),
  ))->Promise.thenResolve(((b, t)) => {
    {tz1: tz1, balance: Some(b), tokens: t}
  })
}

let getAccountOperations = (tz1: Pkh.t, ~isTestNet) => {
  open AccountsReducer
  MezosAPI.getTransactions(~tz1, ~isTestNet)->Promise.thenResolve(operations => {
    {tz1: tz1, operations: operations}
  })
}

open Account

let getBalances = (~accounts, ~isTestNet) =>
  accounts->Belt.Array.map(a => getAccountBalance(~tz1=a.tz1, ~isTestNet))->Js.Promise.all

let getOperations = (~accounts, ~isTestNet) =>
  accounts->Belt.Array.map(a => getAccountOperations(a.tz1, ~isTestNet))->Js.Promise.all

let useTransactionNotif = () => {
  let (accounts, _) = AccountsReducer.useAccountsDispatcher()

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

let useBalancesSync = () => {
  let isTestNet = Store.useIsTestNet()
  let (accounts, dispatch) = AccountsReducer.useAccountsDispatcher()

  let tapError = e => {
    let message = e->_parseError
    Logger.error(message)
    Promise.reject(e)
  }

  let isTestNetRef = React.useRef(isTestNet)
  let accountsRef = React.useRef(accounts)

  isTestNetRef.current = isTestNet
  accountsRef.current = accounts

  let update = () => {
    let accounts = accountsRef.current
    let isTestNet = isTestNetRef.current

    let operationsPromise =
      getOperations(~isTestNet, ~accounts)
      ->Promise.thenResolve(o => dispatch(UpdateOperations(o)))
      ->Promise.catch(tapError)

    let balancesPromise =
      getBalances(~isTestNet, ~accounts)
      ->Promise.thenResolve(b => dispatch(UpdateBalances(b)))
      ->Promise.catch(tapError)

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
