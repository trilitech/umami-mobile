open Belt
open Atoms

let useTheme = () => Jotai.Atom.use(Atoms.themeAtom)
let useContacts = () => Jotai.Atom.use(Atoms.contactsAtom)
let useNetwork = () => Jotai.Atom.use(Atoms.networkAtom)
let useNodeIndex = () => Jotai.Atom.use(Atoms.nodeIndexAtom)
let useAddressMetadatas = () => Jotai.Atom.use(Atoms.addressMetatdadaAtom)
let useBiometricsEnabled = () => Jotai.Atom.use(Atoms.biometricsEnabledAtom)

let useOperations = () => {
  let (operations, setOperations) = Jotai.Atom.use(Atoms.operationsAtom)

  (
    Belt.Map.String.fromArray(operations),
    ops => {
      let arr = ops->Belt.Map.String.toArray

      setOperations(_ => arr)
    },
  )
}

open Balance
let _convertBal = (bs: array<AccountsReducer.balancePayload>) =>
  bs->Belt.Array.reduce(Belt.Map.String.fromArray([]), (acc, curr) => {
    acc->Belt.Map.String.set(
      curr.tz1->Pkh.toString,
      {
        tez: curr.balance,
        tokens: curr.tokens,
      },
    )
  })

let useBalances = () => {
  let (balances, setBalances) = Jotai.Atom.use(Atoms.balancesAtom)

  (
    Belt.Map.String.fromArray(balances),
    bs => {
      let arr = bs->_convertBal->Belt.Map.String.toArray

      setBalances(_ => arr)
    },
  )
}

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

let useAccountsDispatcher = () => {
  let (accounts, set) = Jotai.Atom.use(accountsReduxAtom)
  (accounts, val => set(() => val))
}

let useReset = () => {
  let (_, dispatch) = useAccountsDispatcher()

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
  let (accounts, _) = useAccountsDispatcher()
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

let useContactsDispatcher = () => {
  let (_, setContacts) = useContacts()

  let fn = action => setContacts(prev => ContactReducer.reducer(prev, action))

  let dispatch = React.useCallback1(fn, [])
  dispatch
}
