open Theme
let themeAtom: Jotai.Atom.t<_, _, _> = AtomWithStorage.make("theme", Dark)
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<Account.t>, _, _> = AtomWithStorage.make("accounts", [])

let operationsAtom: Jotai.Atom.t<
  array<(Belt.Map.String.key, array<Operation.t>)>,
  _,
  _,
> = Jotai.Atom.make([])

let balancesAtom: Jotai.Atom.t<
  array<(Belt.Map.String.key, Balance.t)>,
  _,
  _,
> = AtomWithStorage.make("balances", [])

%%private(
  let selectedAccountIndexAtom: Jotai.Atom.t<int, _, _> = AtomWithStorage.make("selectedAccount", 0)
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
    // Reset operations
    set(operationsAtom, [])
    set(selectedAccountIndexAtom, arg)
  },
)

let contactsAtom: Jotai.Atom.t<Contact.contactsMap, _, _> = AtomWithStorage.make(
  "contacts-v1.0.13",
  Belt.Map.String.fromArray([]),
)

type addressMetatdataMap = Belt.Map.String.t<AddressMetadata.t>
let addressMetatdadaAtom: Jotai.Atom.t<addressMetatdataMap, _, _> = AtomWithStorage.make(
  "metadatas-v1.0.13",
  Belt.Map.String.fromArray([]),
)

open Network
%%private(
  let _networkAtom: Jotai.Atom.t<Network.t, _, _> = AtomWithStorage.make("network", Mainnet)
)

let nodeIndexAtom: Jotai.Atom.t<int, _, _> = AtomWithStorage.make("nodeIndex", 0)

let networkAtom: Jotai.Atom.t<
  Network.t,
  Jotai.Atom.Actions.t<(Network.t => Network.t) => unit>,
  _,
> = Jotai.Atom.makeWritableComputed(
  ({get}) => get(_networkAtom),
  ({get: _, set}, arg) => {
    // Reset node to first in the list when we switch networks
    set(nodeIndexAtom, 0)
    // Reset operations
    set(operationsAtom, [])
    // Reset balances
    set(balancesAtom, [])

    set(_networkAtom, arg)
  },
)

// biometricsEnabledAtom needed since keychain API provides no way of
// knowing if there is a password set withouth authenticating
let biometricsEnabledAtom: Jotai.Atom.t<bool, _, _> = AtomWithStorage.make(
  "biometricsEnabled",
  false,
)
