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

open Helpers
open Belt
let makeQueryAutomator = (~fn, ~onResult=_ => (), ~onError=_ => (), ~refreshRate=3000, ()) => {
  let (cancelablFn, cancel) = withCancel(fn)
  let timeoutId = ref(None)

  let rec recursive = () => {
    cancelablFn()
    ->Promise.thenResolve(res => {
      onResult(res)
    })
    ->Promise.catch(err => {
      switch err {
      | PromiseCanceled => ()
      | err => onError(err)
      }
      Promise.resolve()
    })
    ->Promise.finally(_ => {
      timeoutId.contents = Js.Global.setTimeout(recursive, refreshRate)->Some
    })
    ->ignore
  }
  let start = recursive
  let stop = () => {
    cancel.contents()
    timeoutId.contents
    ->Option.map(id => {
      Js.Global.clearTimeout(id)
      timeoutId.contents = None
    })
    ->ignore
  }

  let refresh = () => {
    stop()
    start()
  }

  (start, stop, refresh)
}

let useBalancesSync = () => {
  let updateBalances = useAccountsBalanceUpdate()
  let updateOperations = useAccountsOperationsUpdate()
  let isTestNet = Store.useIsTestNet()

  let isTestNetRef = React.useRef(isTestNet)

  isTestNetRef.current = isTestNet

  let update = () =>
    Promise.all([
      updateBalances(~isTestNet=isTestNetRef.current),
      updateOperations(~isTestNet=isTestNetRef.current),
    ])

  let updateRef = React.useRef(update)

  let masterUpdate = () => updateRef.current()

  let memoAutomator = React.useMemo1(() => makeQueryAutomator(~fn=masterUpdate, ()), [])

  let (_, _, refresh) = memoAutomator

  React.useEffect2(() => {
    refresh()
    None
  }, (isTestNet, refresh))
}
