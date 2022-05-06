type account = {
  name: string,
  balance: option<int>,
  tz1: string,
  sk: string,
  derivationPathIndex: int,
}

// bind to JS' JSON.parse
@scope("JSON") @val
external parseAccount: string => array<account> = "parse"

let themeAtom = Jotai.Atom.make("light")
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let secretAtom: Jotai.Atom.t<array<account>, _, _> = Jotai.Atom.make([])
let selectedAccountAtom: Jotai.Atom.t<option<int>, _, _> = Jotai.Atom.make(None)

let useSnackBar = () => Jotai.Atom.use(snackBarAtom)

let useInit = () => {
  let (_, setTheme) = Jotai.Atom.use(themeAtom)
  let (_, setSecret) = Jotai.Atom.use(secretAtom)
  let (_, setSelected) = Jotai.Atom.use(selectedAccountAtom)
  let (done, setDone) = React.useState(_ => false)

  React.useEffect1(() => {
    Promise.all([Storage.get("theme"), Storage.get("secret"), Storage.get("selectedAccount")])
    ->Promise.thenResolve(result => {
      result[0]->Belt.Option.map(v => setTheme(_ => v))->ignore

      result[1]
      ->Belt.Option.map(s => {
        parseAccount(s)
      })
      ->Belt.Option.map(accounts => {
        setSecret(_ => accounts)
      })
      ->ignore

      result[2]
      ->Belt.Option.map(s => {
        s
        ->Belt.Int.fromString
        ->Belt.Option.map(s => {
          setSelected(_ => Some(s))
        })
      })
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
  let (accounts, setAccounts) = Jotai.Atom.use(secretAtom)

  let setAccounts = fn => {
    setAccounts(fn)
    Js.Json.stringifyAny(fn(accounts))
    ->Belt.Option.map(s => {
      Storage.set("secret", s)
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

  let (account, _) = useAccounts()

  i->Belt.Option.flatMap(i => account->Belt.Array.get(i))
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