open Account
type account = t

// bind to JS' JSON.parse
@scope("JSON") @val
external deserializeAccounts: string => array<account> = "parse"
let deserializeSelectedAccount = s => Belt.Int.fromString(s)
let deserializeTheme = s => s

let themeAtom = Jotai.Atom.make("dark")
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<account>, _, _> = Jotai.Atom.make([])
let selectedAccountAtom: Jotai.Atom.t<option<int>, _, _> = Jotai.Atom.make(None)

let useSnackBar = () => Jotai.Atom.use(snackBarAtom)

let useInit = () => {
  let (_, setTheme) = Jotai.Atom.use(themeAtom)
  let (_, setAccounts) = Jotai.Atom.use(accountsAtom)
  let (_, setSelected) = Jotai.Atom.use(selectedAccountAtom)
  let (done, setDone) = React.useState(_ => false)

  React.useEffect1(() => {
    Promise.all([Storage.get("theme"), Storage.get("accounts"), Storage.get("selectedAccount")])
    ->Promise.thenResolve(result => {
      result[0]->Belt.Option.map(deserializeTheme)->Belt.Option.map(v => setTheme(_ => v))->ignore

      result[1]
      ->Belt.Option.map(deserializeAccounts)
      ->Belt.Option.map(accounts => setAccounts(_ => accounts))
      ->ignore

      result[2]
      ->Belt.Option.map(deserializeSelectedAccount)
      ->Belt.Option.map(s => setSelected(_ => s))
      ->ignore
    })
    ->Promise.thenResolve(_ => setDone(_ => true))
    ->ignore

    None
  }, [])

  done
}

let useTheme = () => {
  let (get, setTheme) = Jotai.Atom.use(themeAtom)

  let setTheme = v => {
    Storage.set("theme", v)->ignore
    setTheme(_ => v)
  }
  (get, setTheme)
}

let useAccounts = () => {
  let (accounts, setAccounts) = Jotai.Atom.use(accountsAtom)

  let setAccounts = fn => {
    setAccounts(fn)
    Js.Json.stringifyAny(fn(accounts))
    ->Belt.Option.map(s => {
      Storage.set("accounts", s)
    })
    ->ignore
  }

  (accounts, setAccounts)
}

let useSelectedAccount = () => {
  let (get, set) = Jotai.Atom.use(selectedAccountAtom)

  let selectedAccount = v => {
    Storage.set("selectedAccount", v->Js.Int.toString)->ignore
    set(_ => Some(v))
  }
  (get, selectedAccount)
}

let useActiveAccount = () => {
  let (i, _) = useSelectedAccount()

  let (accounts, _) = useAccounts()

  i->Belt.Option.flatMap(i => accounts->Belt.Array.get(i))
}

let useTokens = () => {
  switch useActiveAccount() {
  | Some(account) => account.tokens
  | None => []
  }
}

let useWithAccount0 = () => {
  let account = useActiveAccount()

  cb => {
    switch account {
    | Some(account) => cb(account)
    | None => React.null
    }
  }
}

let useWithAccount = cb => {
  let account = useActiveAccount()

  switch account {
  | Some(account) => cb(account)
  | None => React.null
  }
}

let useUpdateAccount = () => {
  let (accounts, setAccounts) = useAccounts()

  a => {
    accounts
    ->Belt.Array.getIndexBy(ac => a.derivationPathIndex == ac.derivationPathIndex)
    ->Belt.Option.map(i => {
      let newAccounts = accounts->Helpers.update(i, a)
      setAccounts(_ => newAccounts)
    })
    ->ignore
  }
}

let useResetAccounts = () => {
  let (_, setAccounts) = useAccounts()
  let (_, setSelectedAccount) = useSelectedAccount()
  () => {
    setSelectedAccount(0)
    setAccounts(_ => [])
  }
}
