let mnemonicAtom: Jotai.Atom.t<array<string>, _, _> = Jotai.Atom.make([])

let useMnemonic = () => {
  Jotai.Atom.use(mnemonicAtom)
}
