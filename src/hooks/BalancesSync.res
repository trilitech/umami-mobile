open UsePrevious
// let updateAccountBalance = (a: Account.t) => {
//   Promise.all2((
//     TaquitoUtils.safeGetBalance(a.tz1),
//     TaquitoUtils.getTokens(a.tz1),
//   ))->Promise.thenResolve(((b, t)) => {
//     {...a, balance: Some(b), tokens: t}
//   })
// }

let getAccountBalance = (tz1: string) => {
  open AccountsReducer
  Promise.all2((TaquitoUtils.safeGetBalance(tz1), TzktAPI.getTokens(tz1)))->Promise.thenResolve(((
    b,
    t,
  )) => {
    {tz1: tz1, balance: Some(b), tokens: t}
  })
}

let getAccountOperations = (tz1: string) => {
  open AccountsReducer
  MezosAPI.getTransactions(tz1)->Promise.thenResolve(operations => {
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

  () =>
    accounts
    ->Belt.Array.map(a => getAccountBalance(a.tz1))
    ->Js.Promise.all
    ->Promise.thenResolve(balances =>
      setAccounts(accounts => updateAccountBalances(accounts, balances))
    )
}

let useAccountsOperationsUpdate = () => {
  let (accounts, setAccounts) = Store.useAccounts()

  () =>
    accounts
    ->Belt.Array.map(a => getAccountOperations(a.tz1))
    ->Js.Promise.all
    ->Promise.thenResolve(balances =>
      setAccounts(accounts => updateAccountOperations(accounts, balances))
    )
}

@module("use-interval")
external useInterval: ('a, int) => unit = "default"

let useTransactionNotif = () => {
  let (accounts, _) = Store.useAccounts()

  let prevAccounts = usePrevious(accounts)
  let notify = SnackBar.useNotification()

  React.useEffect1(() => {
    prevAccounts
    ->Belt.Option.map(prevAccounts => {
      TransNotif.getUpdates(prevAccounts, accounts)->Belt.Array.forEach(notification => {
        open TezHelpers
        notify(`${notification.name} received ${notification.amount->formatBalance}`)
      })
    })
    ->ignore

    None
  }, [accounts])
}

let useBalancesSync = () => {
  // let (accounts, setAccounts) = Store.useAccounts()
  // let notify = SnackBar.useNotification()
  useTransactionNotif()
  let updateBalances = useAccountsBalanceUpdate()
  let updateOperations = useAccountsOperationsUpdate()

  useInterval(() => {
    updateBalances()->ignore
    updateOperations()->ignore
    // updateAccounts(accounts)->Promise.thenResolve(newAccounts => {
    //   // Need this to prevent setStates if promises resolve when logged out.
    //   if isMounted.current {
    //     setAccounts(prevAccounts => {
    //       TransNotif.getUpdates(prevAccounts, newAccounts)->Belt.Array.forEach(notification => {
    //         open TezHelpers
    //         notify(`${notification.name} received ${notification.amount->formatBalance}`)
    //       })

    //       handleAccounts(prevAccounts, newAccounts)
    //     })
    //   }
    // })
    ()
  }, 2000)
}
