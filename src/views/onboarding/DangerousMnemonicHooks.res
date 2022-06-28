let useSuperDangerousMnemonic = () => {
  Jotai.Atom.use(Atoms.superDangerousMnemonicAtom)
}

let useWipeOutOnMount = () => {
  let (_, setMnemonic) = useSuperDangerousMnemonic()
  React.useEffect1(() => {
    setMnemonic(_ => [])
    None
  }, [])
}

let useWipeOutOnUnmount = () => {
  let (_, setMnemonic) = useSuperDangerousMnemonic()

  React.useEffect1(() => {
    Some(() => setMnemonic(_ => []))
  }, [])
}
