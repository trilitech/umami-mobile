let updateAccount = (a: Store.account) =>
  TaquitoUtils.safeGetBalance(a.tz1)->Promise.thenResolve(b => {
    let a = {...a, balance: Some(b)}
    a
  })

let updateAccounts = accounts => {
  let updated = accounts->Belt.Array.map(updateAccount)
  Promise.all(updated)
}

let useBalancesSync = () => {
  let (accounts, setAccounts) = Store.useAccounts()
  let notify = SnackBar.useNotification()

  React.useEffect2(() => {
    if accounts->Belt.Array.every(a => a.balance == None) {
      updateAccounts(accounts)->Promise.thenResolve(accounts => setAccounts(_ => accounts))->ignore
    }

    let id = Js.Global.setInterval(() => {
      updateAccounts(accounts)
      ->Promise.thenResolve(accounts =>
        setAccounts(prev => {
          let updated = TransNotif.updatedAccounts(prev, accounts)

          updated->Belt.Array.forEach(notification => {
            open TezHelpers
            notify(`${notification.name} received ${notification.amount->formatBalance}`)
          })

          accounts
        })
      )
      ->ignore
    }, 3000)

    Some(
      _ => {
        Js.Global.clearInterval(id)
      },
    )
  }, (accounts, setAccounts))
}
