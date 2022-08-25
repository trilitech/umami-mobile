open Account
open Belt
open Atoms
include SavedStore
open Belt

let useActiveAccount = () => {
  let (i, _) = useSelectedAccount()

  let (accounts, _) = AccountsReducer.useAccountsDispatcher()

  accounts->Array.get(i)
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

let useAccountsAndContacts = () => {
  open AccountOrContact
  let contacts = useContacts()
  let (accounts, _) = useAccounts()
  let allContacts = Array.concat(
    accounts->Array.map(a => AccountCard(a)),
    contacts->Array.map(c => ContactCard(c)),
  )
  allContacts
}

let useIsTestNet = () => {
  let (network, _) = SavedStore.useNetwork()
  network != Mainnet
}

let useGetTezosDomain = () => {
  let (metadatas, _) = SavedStore.useAddressMetadatas()
  tz1 => metadatas->Map.String.get(tz1)->Option.flatMap(d => d.tzDomain)
}
let useGetTezosProfile = () => {
  let (metadatas, _) = SavedStore.useAddressMetadatas()
  tz1 => metadatas->Map.String.get(tz1)->Option.flatMap(d => d.tzProfile)
}
