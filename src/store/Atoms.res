let themeAtom = Jotai.Atom.make("dark")
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<Account.t>, _, _> = Jotai.Atom.make([])
let selectedAccountAtom: Jotai.Atom.t<int, _, _> = Jotai.Atom.make(0)
let contactsAtom: Jotai.Atom.t<array<Contact.t>, _, _> = Jotai.Atom.make([])
open Network
let networkAtom: Jotai.Atom.t<Network.t, _, _> = Jotai.Atom.make(Mainnet)
let superDangerousMnemonicAtom: Jotai.Atom.t<array<string>, _, _> = Jotai.Atom.make([])
