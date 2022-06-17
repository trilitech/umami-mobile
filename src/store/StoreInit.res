open Atoms

open Belt
module Deserializers = {
  // Totally unsafe
  @scope("JSON") @val
  external deserializeAccounts: string => array<Account.t> = "parse"
  let deserializeSelectedAccount = s => Belt.Int.fromString(s)
  let deserializeTheme = (s: string) => s
}

let _useIniter = (hook, key: string, deserializer) => {
  let (_, set) = hook()
  () =>
    Storage.get(key)->Promise.thenResolve(result =>
      result->Belt.Option.map(r => set(_ => deserializer(r)))
    )
}

let useIniter = atom => _useIniter(() => Jotai.Atom.use(atom))

let useInit = () => {
  open Deserializers
  let (done, setDone) = React.useState(_ => false)

  let initers = [
    useIniter(themeAtom, "theme", deserializeTheme),
    useIniter(accountsAtom, "accounts", deserializeAccounts),
    useIniter(selectedAccountAtom, "selectedAccount", deserializeSelectedAccount),
  ]

  let memoIniters = React.useMemo1(() => initers, [])

  React.useEffect2(() => {
    Promise.all(initers->Array.map(i => i()))->Promise.thenResolve(_ => setDone(_ => true))->ignore

    None
  }, (memoIniters, setDone))

  done
}
