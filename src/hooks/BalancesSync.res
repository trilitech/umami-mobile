open UsePrevious
// let updateAccountBalance = (a: Account.t) => {
//   Promise.all2((
//     TaquitoUtils.safeGetBalance(a.tz1),
//     TaquitoUtils.getTokens(a.tz1),
//   ))->Promise.thenResolve(((b, t)) => {
//     {...a, balance: Some(b), tokens: t}
//   })
// }

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
// let updateAccounts = accounts => {
//   let updated = accounts->Belt.Array.map(updateAccountBalance)
//   Promise.all(updated)
// }

// let handleAccounts = (old: array<Store.account>, new_: array<Store.account>) => {
//   old->Belt.Array.map(oldA => {
//     let updated = new_->Belt.Array.getBy(acc => acc.tz1 == oldA.tz1)
//     switch updated {
//     | Some(account) => account
//     | None => oldA
//     }
//   })
// }

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

let useAccountsBalanceUpdate = () => {
  let (accounts, setAccounts) = Store.useAccounts()

  (~isTestNet) => {
    accounts
    ->Belt.Array.map(a => getAccountBalance(~tz1=a.tz1, ~isTestNet))
    ->Js.Promise.all
    ->Promise.thenResolve(balances => {
      setAccounts(accounts => updateAccountBalances(accounts, balances))
    })
  }
}

let useAccountsOperationsUpdate = () => {
  let (accounts, setAccounts) = Store.useAccounts()

  (~isTestNet) =>
    accounts
    ->Belt.Array.map(a => getAccountOperations(a.tz1, ~isTestNet))
    ->Js.Promise.all
    ->Promise.thenResolve(balances =>
      setAccounts(accounts => updateAccountOperations(accounts, balances))
    )
}

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

open AccountsReducer
open Helpers
let useBalancesSync = () => {
  let updateBalances = useAccountsBalanceUpdate()
  let updateOperations = useAccountsOperationsUpdate()
  let isTestNet = Store.useIsTestNet()
  let dispatch = AccountsReducer.useAccountsDispatcher()
  let notify = SnackBar.useNotification()

  let updateWithCancel =
    (() => Promise.all([updateBalances(~isTestNet), updateOperations(~isTestNet)]))->withCancel

  let updateWithCancelRef = React.useRef(updateWithCancel)
  let timeoutIdRef = React.useRef(None)

  updateWithCancelRef.current = updateWithCancel

  let start = React.useCallback1(() => {
    let rec recursiveUpdate = () => {
      let (update, _) = updateWithCancelRef.current

      update()
      ->Promise.catch(err => {
        switch err {
        | PromiseCanceled => ()
        | err => err->getMessage->notify
        }
        Promise.resolve([])
      })
      ->Promise.finally(_ => {
        timeoutIdRef.current = Js.Global.setTimeout(recursiveUpdate, 3000)->Some
      })
      ->ignore
    }

    recursiveUpdate()->ignore
  }, [])

  React.useEffect1(() => {
    start()
    None
  }, [start])

  React.useEffect2(() => {
    let (_, cancel) = updateWithCancelRef.current

    dispatch(ResetAssetInfos)
    cancel.contents()
    None
  }, (isTestNet, dispatch))

  React.useEffect1(() => {
    Some(() => timeoutIdRef.current->Belt.Option.map(id => Js.Global.clearTimeout(id))->ignore)
  }, [])
}
