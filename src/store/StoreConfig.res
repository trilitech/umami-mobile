open Belt

// This type couples
// - RN Storage key
// - Jotai atom
// - deserializer/serializer to string for RN Storage

type t<'a> = {
  key: string,
  atom: Jotai.Atom.t<'a, Jotai.Atom.Actions.set<'a>, [#readable | #writable | #primitive]>,
  deserializer: string => 'a,
  serializer: 'a => option<string>,
}

module Serializers = {
  let serializeAccounts = Js.Json.stringifyAny
  let serializeSelectedAccount = s => s->Js.Int.toString->Some
  let serializeTheme = s => s->Theme.toString->Some
  let serializeContacts = (c: Contact.contactsMap) => {
    c->Belt.Map.String.toArray->Js.Json.stringifyAny
  }

  let serializeAddressMetadatas = (a: Belt.Map.String.t<AddressMetadata.t>) => {
    a->Belt.Map.String.toArray->Js.Json.stringifyAny
  }
  let serializeNetwork = (n: Network.t) => n->Network.toString->Some
}

let _withSave = (stateHook, serializer, key: string, ()) => {
  let (value, setValue) = stateHook()

  // Have to do this ref and memo dance to keep the setter stable...
  let valueRef = React.useRef(value)
  valueRef.current = value

  let setValueWithSave = fn => {
    setValue(fn)

    fn(valueRef.current)
    ->serializer
    ->Belt.Option.map(s => {
      Storage.set(key, s)
    })
    ->ignore
  }

  let stableSetValue = React.useMemo(() => setValueWithSave)

  (value, stableSetValue)
}

module Deserializers = {
  open JSONparse
  // Totally unsafe
  let deserializeAccounts: string => array<Account.t> = unsafeJSONParse
  let deserializeSelectedAccount = s => Belt.Int.fromString(s)->Belt.Option.getWithDefault(0)
  let deserializeTheme = Theme.fromString
  let deserializeContacts: string => Map.String.t<Contact.t> = s =>
    s->unsafeJSONParse->Belt.Map.String.fromArray

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

let theme = {
  key: "theme",
  atom: Atoms.themeAtom,
  deserializer: Deserializers.deserializeTheme,
  serializer: Serializers.serializeTheme,
}

let accounts = {
  key: "accounts",
  atom: Atoms.accountsAtom,
  deserializer: Deserializers.deserializeAccounts,
  serializer: Serializers.serializeAccounts,
}

let selectedAccount = {
  key: "selectedAccount",
  atom: Atoms.selectedAccountAtom,
  deserializer: Deserializers.deserializeSelectedAccount,
  serializer: Serializers.serializeSelectedAccount,
}

let contacts = {
  key: "contacts",
  atom: Atoms.contactsAtom,
  deserializer: Deserializers.deserializeContacts,
  serializer: Serializers.serializeContacts,
}

let network = {
  key: "network",
  atom: Atoms.networkAtom,
  deserializer: Deserializers.deserializeNetwork,
  serializer: Serializers.serializeNetwork,
}

let addressMetadatas = {
  key: "addressMetadatas",
  atom: Atoms.addressMetatdadaAtom,
  deserializer: Deserializers.deserializeAddressMetadatas,
  serializer: Serializers.serializeAddressMetadatas,
}
