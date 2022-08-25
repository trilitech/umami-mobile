open Atoms

module Serializers = {
  let serializeAccounts = Js.Json.stringifyAny
  let serializeSelectedAccount = s => s->Js.Int.toString->Some
  let serializeTheme = s => s->Some
  let serializeContacts = Js.Json.stringifyAny
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

let withSave = atom => _withSave(() => Jotai.Atom.use(atom))

let useTheme = withSave(themeAtom, Serializers.serializeTheme, "theme")
let useAccounts = withSave(accountsAtom, Serializers.serializeAccounts, "accounts")
let useSelectedAccount = withSave(
  selectedAccountAtom,
  Serializers.serializeSelectedAccount,
  "selectedAccount",
)

let useContacts = withSave(contactsAtom, Serializers.serializeContacts, "contacts")

let useNetwork = withSave(networkAtom, Serializers.serializeNetwork, "network")

let useAddressMetadatas = withSave(
  addressMetatdadaAtom,
  Serializers.serializeAddressMetadatas,
  "addressMetadatas",
)
