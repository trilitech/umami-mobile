open Theme
let themeAtom: Jotai.Atom.t<_, _, _> = AtomStorage.make("theme", Dark)
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<Account.t>, _, _> = AtomStorage.make("accounts", [])

%%private(
  let selectedAccountIndexAtom: Jotai.Atom.t<int, _, _> = AtomStorage.make("selectedAccount", 0)
)

let selectedAccount: Jotai.Atom.t<
  option<Account.t>,
  Jotai.Atom.Actions.t<(int => int) => unit>,
  _,
> = Jotai.Atom.makeWritableComputed(
  ({get}) => {
    let index = get(selectedAccountIndexAtom)
    let accounts = get(accountsAtom)
    accounts->Belt.Array.get(index)
  },
  ({get: _, set}, arg) => {
    set(selectedAccountIndexAtom, arg)
  },
)

let contactsAtom: Jotai.Atom.t<Contact.contactsMap, _, _> = AtomStorage.make(
  "contacts-v1.0.13",
  Belt.Map.String.fromArray([]),
)

type addressMetatdataMap = Belt.Map.String.t<AddressMetadata.t>
let addressMetatdadaAtom: Jotai.Atom.t<addressMetatdataMap, _, _> = AtomStorage.make(
  "metadatas-v1.0.13",
  Belt.Map.String.fromArray([]),
)

open Network
%%private(let networkAtom: Jotai.Atom.t<Network.t, _, _> = AtomStorage.make("network", Mainnet))

let nodeIndexAtom: Jotai.Atom.t<int, _, _> = AtomStorage.make("nodeIndex", 0)

let networkAtom: Jotai.Atom.t<
  Network.t,
  Jotai.Atom.Actions.t<(Network.t => Network.t) => unit>,
  _,
> = Jotai.Atom.makeWritableComputed(
  ({get}) => get(networkAtom),
  ({get: _, set}, arg) => {
    // Reset node to first in the list when we switch networks
    set(nodeIndexAtom, 0)
    set(networkAtom, arg)
  },
)

// biometricsEnabledAtom needed since keychain API provides no way of
// knowing if there is a password set withouth authenticating
let biometricsEnabledAtom: Jotai.Atom.t<bool, _, _> = AtomStorage.make("biometricsEnabled", false)
