open Account
open Atoms
include SavedStore

let useActiveAccount = () => {
  let (i, _) = useSelectedAccount()

  let (accounts, _) = AccountsReducer.useAccountsDispatcher()

  accounts->Belt.Array.get(i)
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

let useReset = () => {
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()
  let (_, setSelectedAccount) = useSelectedAccount()
  let (_, setNetwork) = useNetwork()

  () => {
    setSelectedAccount(_ => 0)
    dispatch(Reset)
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
