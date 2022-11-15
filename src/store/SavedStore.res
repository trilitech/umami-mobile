let _withSave = (stateHook, serializer, key: string, ()) => {
  let (value, setValue) = stateHook()

  // Have to do this ref and memo dance to keep the setter stable...
  let valueRef = React.useRef(value)
  valueRef.current = value

  let setValueWithSave = fn => {
    setValue(fn)

    fn(valueRef.current)
    ->serializer
    ->Belt.Option.map(s => {
      Storage.set(key, s)
    })
    ->ignore
  }

  let stableSetValue = React.useMemo(() => setValueWithSave)

  (value, stableSetValue)
}

let _withSave = atom => _withSave(() => Jotai.Atom.use(atom))

let withSave = (c: StoreConfig.t<'a>) => _withSave(c.atom, c.serializer, c.key)

open StoreConfig
// Create state hooks with config infos
let useTheme = withSave(theme)
let useAccounts = withSave(accounts)
let useSelectedAccount = withSave(selectedAccount)
let useContacts = withSave(contacts)
let useNetwork = withSave(network)
let useNodeIndex = withSave(nodeIndex)
let useAddressMetadatas = withSave(addressMetadatas)
let useBiometricsEnabled = withSave(biometricsEnabled)
