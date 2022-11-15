open Theme
let themeAtom: Jotai.Atom.t<Theme.t, _, _> = Jotai.Atom.make(Dark)
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<Account.t>, _, _> = Jotai.Atom.make([])
let selectedAccountAtom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(0)

let contactsAtom: Jotai.Atom.t<Contact.contactsMap, _, _> = Jotai.Atom.make(
  Belt.Map.String.fromArray([]),
)

type addressMetatdataMap = Belt.Map.String.t<AddressMetadata.t>
let addressMetatdadaAtom: Jotai.Atom.t<addressMetatdataMap, _, _> = Jotai.Atom.make(
  Belt.Map.String.fromArray([]),
)

open Network
let networkAtom: Jotai.Atom.t<Network.t, _, _> = Jotai.Atom.make(Mainnet)
let nodeIndexAtom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(0)

// biometricsEnabledAtom needed since keychain API provides no way of
// knowing if there is a password set withouth authenticating
let biometricsEnabledAtom: Jotai.Atom.t<bool, _, _> = Jotai.Atom.make(false)
