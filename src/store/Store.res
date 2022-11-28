open Account
open Belt
open Atoms
include SavedStore

let useSelectedAccount = () => Jotai.Atom.use(Atoms.selectedAccount)

let useSnackBar = () => Jotai.Atom.use(snackBarAtom)

let useTokens = () => {
  let (account, _) = useSelectedAccount()
  switch account {
  | Some(account) => account.tokens
  | None => []
  }
}

let useWithAccount = cb => {
  let (account, _) = useSelectedAccount()

  switch account {
  | Some(account) => cb(account)
  | None => React.null
  }
}

let useReset = () => {
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()

  let (_, setNetwork) = useNetwork()
  let (_, setNodeIndex) = useNodeIndex()

  () => {
    dispatch(Reset)
    setNetwork(_ => Mainnet)
    setNodeIndex(_ => 0)
  }
}

let useAccountsAndContacts = () => {
  open AccountOrContact
  let (contacts, _) = useContacts()
  let (accounts, _) = useAccounts()
  let allContacts = Array.concat(
    accounts->Array.map(a => AccountCard(a)),
    contacts->Contact.toArray->Array.map(c => ContactCard(c)),
  )
  allContacts
}

let useAddressExists = () => {
  let accountsAndContacts = useAccountsAndContacts()
  let allAddresses = accountsAndContacts->Array.map(AccountOrContact.getAddress)

  tz1 => allAddresses->Array.some(existing => existing == tz1)
}

let useGetTezosDomain = () => {
  let (metadatas, _) = useAddressMetadatas()
  tz1 => metadatas->Map.String.get(tz1)->Option.flatMap(d => d.tzDomain)
}
let useGetTezosProfile = () => {
  let (metadatas, _) = useAddressMetadatas()
  tz1 => metadatas->Map.String.get(tz1)->Option.flatMap(d => d.tzProfile)
}
