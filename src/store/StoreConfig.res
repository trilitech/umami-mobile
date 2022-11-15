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

  let serializeNodeIndex = s => s->Js.Int.toString->Some
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

external arrToTuple: array<Js.Json.t> => (Belt.Map.String.key, 'a) = "%identity"
module Deserializers = {
  open JSONparse
  // Totally unsafe
  let deserializeAccounts: string => array<Account.t> = unsafeJSONParse
  let deserializeSelectedAccount = s => Belt.Int.fromString(s)->Belt.Option.getWithDefault(0)
  let deserializeTheme = Theme.fromString

  // We need to handle contacts on disk pre version 1.0.8 that are not saved in tuples
  let deserializeContacts: string => Map.String.t<Contact.t> = s =>
    switch Js.Json.classify(s->Js.Json.parseExn) {
    | JSONArray(a) =>
      a->Array.map(c =>
        switch Js.Json.classify(c) {
        // if it's already an array assume it's the good format and do nothing
        | JSONArray(keyValue) => keyValue->Some
        // if its an object (pre 1.0.8) format as tuple
        | JSONObject(obj) => obj->Js.Dict.get("tz1")->Option.map(tz1 => [tz1, c])
        | _ => None
        }
      )
    | _ => []
    }
    ->Helpers.filterNone
    ->Array.map(arrToTuple) // TODO remove this unsafe part and implement more precise typechecks with JsonCombinators
    ->Belt.Map.String.fromArray

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

  let deserializeNodeIndex = s => Belt.Int.fromString(s)->Belt.Option.getWithDefault(0)
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

let nodeIndex = {
  key: "nodeIndex",
  atom: Atoms.nodeIndexAtom,
  deserializer: Deserializers.deserializeNodeIndex,
  serializer: Serializers.serializeNodeIndex,
}

let addressMetadatas = {
  key: "addressMetadatas",
  atom: Atoms.addressMetatdadaAtom,
  deserializer: Deserializers.deserializeAddressMetadatas,
  serializer: Serializers.serializeAddressMetadatas,
}

let biometricsEnabled = {
  key: "biometricsEnabled",
  atom: Atoms.biometricsEnabledAtom,
  deserializer: str =>
    switch str {
    | "true" => true
    | _ => false
    },
  serializer: val =>
    switch val {
    | true => "true"->Some
    | false => "false"->Some
    },
}
