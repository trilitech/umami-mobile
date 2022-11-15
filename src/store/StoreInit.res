open Belt

let _useIniter = (hook, key: string, deserializer) => {
  let (_, set) = hook()
  () =>
    Storage.get(key)->Promise.thenResolve(result =>
      result->Belt.Option.map(r => set(_ => deserializer(r)))
    )
}

let _useIniter = atom => _useIniter(() => Jotai.Atom.use(atom))

let useIniter = (c: StoreConfig.t<'a>) => _useIniter(c.atom, c.key, c.deserializer)

// Triggers store initialization.
// Returns true when store is successfully updated against RNStorage.

let useInit = () => {
  let (done, setDone) = React.useState(_ => false)

  open StoreConfig
  let initers = [
    useIniter(theme),
    useIniter(accounts),
    useIniter(selectedAccount),
    useIniter(contacts),
    useIniter(network),
    useIniter(addressMetadatas),
    useIniter(biometricsEnabled),
    useIniter(nodeIndex),
  ]

  let memoIniters = React.useMemo1(() => initers, [])

  React.useEffect2(() => {
    Promise.all(initers->Array.map(i => i()))->Promise.thenResolve(_ => setDone(_ => true))->ignore

    None
  }, (memoIniters, setDone))

  done
}
