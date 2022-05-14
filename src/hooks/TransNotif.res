type update = {name: string, amount: int}

let getUpdates = (prevAccounts: array<Store.account>, newAccounts: array<Store.account>) => {
  prevAccounts->Belt.Array.reduce([], (acc, currentAccount) => {
    let newAccount = newAccounts->Belt.Array.getBy(a => a.tz1 == currentAccount.tz1)

    let newBalance = newAccount->Belt.Option.flatMap(a => a.balance)

    let default = Belt.Array.concat(acc, [])

    Helpers.both(currentAccount.balance, newBalance)->Belt.Option.mapWithDefault(default, ((
      oldBalance,
      newBalance,
    )) => {
      let credit = newBalance - oldBalance

      if credit > 0 {
        Belt.Array.concat(acc, [{name: currentAccount.name, amount: credit}])
      } else {
        default
      }
    })
  })
}
