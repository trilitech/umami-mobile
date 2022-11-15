let getAccountBalance = (~tz1: Pkh.t, ~network) => {
  open AccountsReducer
  Promise.all2((
    TaquitoUtils.getBalance(~tz1, ~network),
    TzktAPI.getTokens(~tz1, ~network),
  ))->Promise.thenResolve(((b, t)) => {
    {tz1: tz1, balance: Some(b), tokens: t}
  })
}

let getAccountOperations = (tz1: Pkh.t, ~network) => {
  open AccountsReducer
  MezosAPI.getTransactions(~tz1, ~network)->Promise.thenResolve(operations => {
    {tz1: tz1, operations: operations}
  })
}

open Account

let getBalances = (~accounts, ~network) =>
  accounts->Belt.Array.map(a => getAccountBalance(~tz1=a.tz1, ~network))->Js.Promise.all

let getOperations = (~accounts, ~network) =>
  accounts->Belt.Array.map(a => getAccountOperations(a.tz1, ~network))->Js.Promise.all

// TODO reimplement transaction notifications

// let useTransactionNotif = () => {
//   let (accounts, _) = AccountsReducer.useAccountsDispatcher()

//   let prevAccounts = usePrevious(accounts)
//   let notify = SnackBar.useNotification()

//   React.useEffect3(() => {
//     prevAccounts
//     ->Belt.Option.map(prevAccounts => {
//       TransNotif.getUpdates(prevAccounts, accounts)->Belt.Array.forEach(notification => {
//         open TezHelpers
//         notify(`${notification.name} received ${notification.amount->formatBalance}`)
//       })
//     })
//     ->ignore

//     None
//   }, (accounts, notify, prevAccounts))
// }

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

let tapError = e => {
  let message = e->_parseError
  Logger.error(message)
  Promise.resolve()
}

let useQueryWithRefetchInterval = (queryFn, queryKey) => {
  ReactQuery.useQuery(
    ReactQuery.queryOptions(
      ~queryFn,
      ~queryKey,
      ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
      ~refetchInterval=ReactQuery.refetchInterval(#number(3000)),
      (),
    ),
  )
}

let useBalancesAndOpsSync = () => {
  let (network, _) = Store.useNetwork()
  let (accounts, dispatch) = AccountsReducer.useAccountsDispatcher()

  useQueryWithRefetchInterval(
    _ =>
      getOperations(~network, ~accounts)
      ->Promise.thenResolve(o => dispatch(UpdateOperations(o)))
      ->Promise.catch(tapError),
    "operations",
  )->ignore

  useQueryWithRefetchInterval(
    _ =>
      getBalances(~network, ~accounts)
      ->Promise.thenResolve(b => dispatch(UpdateBalances(b)))
      ->Promise.catch(tapError),
    "balances",
  )->ignore
}
