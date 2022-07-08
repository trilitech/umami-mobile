%%private(
  let useOnUnfocus = cb => {
    let isFocused = ReactNavigation.Native.useIsFocused()
    React.useEffect1(() => {
      if !isFocused {
        cb()
      }
      None
    }, [isFocused])
  }
)

let useEphemeralState = neutralValue => {
  let (get, set) = React.useState(_ => neutralValue)
  useOnUnfocus(() => set(_ => neutralValue))
  (get, set)
}
