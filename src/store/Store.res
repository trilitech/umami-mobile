open Account
open Belt
open Atoms
include SavedStore

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
  let (_, setNodeIndex) = useNodeIndex()

  () => {
    setSelectedAccount(_ => 0)
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
