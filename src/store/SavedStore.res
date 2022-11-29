let useTheme = () => Jotai.Atom.use(Atoms.themeAtom)
let useAccounts = () => Jotai.Atom.use(Atoms.accountsAtom)
let useContacts = () => Jotai.Atom.use(Atoms.contactsAtom)
let useNetwork = () => Jotai.Atom.use(Atoms.networkAtom)
let useNodeIndex = () => Jotai.Atom.use(Atoms.nodeIndexAtom)
let useAddressMetadatas = () => Jotai.Atom.use(Atoms.addressMetatdadaAtom)
let useBiometricsEnabled = () => Jotai.Atom.use(Atoms.biometricsEnabledAtom)

let useOperations = () => {
  let (operations, setOperations) = Jotai.Atom.use(Atoms.operationsAtom)

  (
    Belt.Map.String.fromArray(operations),
    ops => {
      let arr = ops->Belt.Map.String.toArray

      setOperations(_ => arr)
    },
  )
}
