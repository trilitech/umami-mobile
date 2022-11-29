open Account
open Belt
open Atoms
include SavedStore

let useSelectedAccount = () => Jotai.Atom.use(Atoms.selectedAccount)

let useSnackBar = () => Jotai.Atom.use(snackBarAtom)

let useTokens = () => {
  let (account, _) = useSelectedAccount()
  let (balances, _) = useBalances()
  account
  ->Belt.Option.flatMap(account => balances->Belt.Map.String.get(account.tz1->Pkh.toString))
  ->Belt.Option.map(b => b.tokens)
  ->Belt.Option.getWithDefault([])
}

let useGetBalance = () => {
  let (balances, _) = useBalances()
  (pkh: Pkh.t) => balances->Belt.Map.String.get(pkh->Pkh.toString)
}

let useSelectedAccountTezBalance = () => {
  let (account, _) = useSelectedAccount()
  let getBalance = useGetBalance()
  account->Belt.Option.flatMap(account => getBalance(account.tz1))->Belt.Option.flatMap(b => b.tez)
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

  open Network
  () => {
    dispatch(Reset)
    setNetwork(_ => Mainnet)
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
