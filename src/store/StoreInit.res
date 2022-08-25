open Atoms

open Belt

@scope("JSON") @val
external unsafeJSONParse: string => 'a = "parse"

module Deserializers = {
  // Totally unsafe
  let deserializeAccounts: string => array<Account.t> = unsafeJSONParse
  let deserializeSelectedAccount = s => Belt.Int.fromString(s)->Belt.Option.getWithDefault(0)
  let deserializeTheme = (s: string) => s
  let deserializeContacts: string => array<Contact.t> = unsafeJSONParse

  let deserializeAddressMetadatas: string => Map.String.t<AddressMetadata.t> = s =>
    s->unsafeJSONParse->Belt.Map.String.fromArray

  let deserializeNetwork = s => {
    open Network
    switch s {
    | "ghostnet" => Ghostnet
    | "mainnet" => Mainnet
    | _ => Mainnet
    }
  }
}

let _useIniter = (hook, key: string, deserializer) => {
  let (_, set) = hook()
  () =>
    Storage.get(key)->Promise.thenResolve(result =>
      result->Belt.Option.map(r => set(_ => deserializer(r)))
    )
}

let useIniter = atom => _useIniter(() => Jotai.Atom.use(atom))

// Triggers store initialization.
// Returns true when store is updated against RNStorage.
let useInit = () => {
  open Deserializers
  let (done, setDone) = React.useState(_ => false)

  let initers = [
    useIniter(themeAtom, "theme", deserializeTheme),
    useIniter(accountsAtom, "accounts", deserializeAccounts),
    useIniter(selectedAccountAtom, "selectedAccount", deserializeSelectedAccount),
    useIniter(contactsAtom, "contacts", deserializeContacts),
    useIniter(networkAtom, "network", deserializeNetwork),
    useIniter(addressMetatdadaAtom, "addressMetadatas", deserializeAddressMetadatas),
  ]

  let memoIniters = React.useMemo1(() => initers, [])

  React.useEffect2(() => {
    Promise.all(initers->Array.map(i => i()))->Promise.thenResolve(_ => setDone(_ => true))->ignore

    None
  }, (memoIniters, setDone))

  done
}
