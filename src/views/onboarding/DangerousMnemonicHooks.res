%%private(
  let superDangerousMnemonicAtom: Jotai.Atom.t<array<string>, _, _> = Jotai.Atom.make([])
  let useSuperDangerousMnemonic = () => {
    Jotai.Atom.use(superDangerousMnemonicAtom)
  }

  let routesThatNeedMnemonic = ["NewSecret", "RecordRecoveryPhrase", "NewPassword"]

  let useNeedsMnemonic = () => {
    let routeName = NavUtils.useRouteName()
    routeName->Belt.Option.mapWithDefault(false, n => {
      routesThatNeedMnemonic->Belt.Array.some(e => e == n)
    })
  }

  let useReset = () => {
    let (_, set) = useSuperDangerousMnemonic()
    () => set(_ => [])
  }
)

let useResetOnUnmount = () => {
  let reset = useReset()
  React.useEffect1(() => Some(reset), [])
}

let useMnemonic = () => {
  let (get, set) = useSuperDangerousMnemonic()
  let reset = useReset()

  let isFocused = ReactNavigation.Native.useIsFocused()
  let needsMnemonic = useNeedsMnemonic()

  React.useEffect3(() => {
    if !isFocused && !needsMnemonic {
      reset()
    }
    None
  }, (isFocused, needsMnemonic, reset))

  (get, set)
}
