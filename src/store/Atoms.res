let themeAtom = Jotai.Atom.make("dark")
let snackBarAtom: Jotai.Atom.t<option<React.element>, _, _> = Jotai.Atom.make(None)
let accountsAtom: Jotai.Atom.t<array<Account.t>, _, _> = Jotai.Atom.make([])
let selectedAccountAtom: Jotai.Atom.t<option<int>, _, _> = Jotai.Atom.make(None)
