open Atoms

module Serializers = {
  let serializeAccounts = Js.Json.stringifyAny
  let serializeSelectedAccount = s => s->Belt.Option.map(Js.Int.toString)
  let serializeTheme = s => s->Some
  let serializeContacts = Js.Json.stringifyAny
  let serializeNetwork = (n: Network.t) => n->Network.toString->Some
}

let _withSave = (stateHook, serializer, key: string, ()) => {
  let (value, setValue) = stateHook()

  let setValueWithSave = fn => {
    setValue(fn)
    fn(value)->serializer->Belt.Option.map(s => Storage.set(key, s))->ignore
  }

  (value, setValueWithSave)
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
