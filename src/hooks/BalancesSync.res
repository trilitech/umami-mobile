let updateAccountBalance = (a: Store.account) => {
  Promise.all2((
    TaquitoUtils.safeGetBalance(a.tz1),
    TaquitoUtils.getTokens(a.tz1),
  ))->Promise.thenResolve(((b, t)) => {
    {...a, balance: Some(b), tokens: t}
  })
}

let updateAccounts = accounts => {
  let updated = accounts->Belt.Array.map(updateAccountBalance)
  Promise.all(updated)
}

let handleAccounts = (old: array<Store.account>, new_: array<Store.account>) => {
  old->Belt.Array.map(oldA => {
    let updated = new_->Belt.Array.getBy(acc => acc.tz1 == oldA.tz1)
    switch updated {
    | Some(account) => account
    | None => oldA
    }
  })
}

@module("use-interval")
external useInterval: ('a, int) => unit = "default"

let useBalancesSync = () => {
  let (accounts, setAccounts) = Store.useAccounts()
  let notify = SnackBar.useNotification()
  let isMounted = React.useRef(true)

  React.useEffect1(() => {
    Some(() => isMounted.current = false)
  }, [])

  useInterval(() => {
    open Belt.Array
    updateAccounts(accounts)->Promise.thenResolve(updatedAccounts => {
      // let accountsAddedSince = accounts->length > updatedAccounts->length

      if isMounted.current {
        setAccounts(prev => {
          let updates = TransNotif.updatedAccounts(prev, updatedAccounts)
          updates->Belt.Array.forEach(notification => {
            open TezHelpers
            notify(`${notification.name} received ${notification.amount->formatBalance}`)
          })

          handleAccounts(prev, updatedAccounts)
        })
      }
    })
  }, 2000)
}
