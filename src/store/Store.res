open Account
open Atoms
include SavedStore

let useActiveAccount = () => {
  let (i, _) = useSelectedAccount()

  let (accounts, _) = useAccounts()

  i->Belt.Option.flatMap(i => accounts->Belt.Array.get(i))
}

let useSnackBar = () => Jotai.Atom.use(snackBarAtom)

let useTokens = () => {
  switch useActiveAccount() {
  | Some(account) => account.tokens
  | None => []
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

let useReset = () => {
  let (_, setAccounts) = useAccounts()
  let (_, setSelectedAccount) = useSelectedAccount()
  let (_, setNetwork) = useNetwork()

  () => {
    setSelectedAccount(_ => Some(0))
    setAccounts(_ => [])
    setNetwork(_ => Mainnet)
  }
}

let useContactsDispatcher = () => {
  let (_, setContacts) = SavedStore.useContacts()

  action => setContacts(prev => ContactReducer.reducer(prev, action))
}
let useContacts = () => {
  let (contacts, _) = SavedStore.useContacts()
  contacts
}

let useIsTestNet = () => {
  let (network, _) = SavedStore.useNetwork()
  switch network {
  | Mainnet => false
  | _ => true
  }
}
