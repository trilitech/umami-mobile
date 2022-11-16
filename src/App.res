%%raw(`
require('./ignoreWarnings')
`)

let useLogInit = () =>
  AsyncInit.useAsyncInit(
    ~init=() => Logger.init(),
    ~errMsgPrefix="Failed to initialize logger.",
    (),
  )

let useDeviceIdInit = () =>
  AsyncInit.useAsyncInit(
    ~init=() =>
      DeviceInfo.getUniqueId()->Promise.thenResolve(id => DeviceId.id.contents = id->Some),
    ~errMsgPrefix="Failed to initialize unique device ID.",
    (),
  )

let useLocalStorageShimForBeaconInit = () =>
  AsyncInit.useAsyncInit(
    ~init=Beacon.hydrateBeaconStorage,
    ~errMsgPrefix="Failed to initialize beacon local storage shim.",
    (),
  )

let useHasAccount = () => {
  let (accounts, _) = AccountsReducer.useAccountsDispatcher()
  accounts->Belt.Array.get(0)->Belt.Option.isSome
}

// Set bg color via react navigation theme otherwise we get glitches
let useNavTheme = () => {
  open Paper.ThemeProvider
  let theme = useTheme()
  let backgroundColor = Theme.colors(theme)->Theme.Colors.background

  let theme = ReactNavigation.Native.useTheme()
  let colors = {...theme.colors, background: backgroundColor}

  {...theme, colors: colors}
}

module MemoizedRouter = {
  open ReactNavigation
  @react.component
  let make = React.memo((~hasAccount) => {
    let navTheme = useNavTheme()
    <SnackbarDisplayer>
      <Native.NavigationContainer theme={navTheme}>
        {
          // Allow scrollin if screen ever overflows (which should not happen on any device)
          hasAccount ? <OnboardRouter /> : <OffboardRouter />
        }
      </Native.NavigationContainer>
    </SnackbarDisplayer>
  })
}

module Router = {
  @react.component
  let make = () => {
    let hasAccount = useHasAccount()
    <MemoizedRouter hasAccount />
  }
}

let client = ReactQuery.Provider.createClient()

module MemoizedApp = {
  @react.component
  let make = React.memo((~allReady) => {
    <ReactQuery.Provider client>
      <UmamiThemeProvider> {allReady ? <Router /> : React.null} </UmamiThemeProvider>
    </ReactQuery.Provider>
  })
}

@react.component
let app = () => {
  let initalizations = [useLogInit(), useDeviceIdInit(), useLocalStorageShimForBeaconInit()]
  let allReady = initalizations->Belt.Array.every(i => i)

  // Prevent rerenders sinces useInit is hooked to all the states

  <React.Suspense fallback=React.null> <MemoizedApp allReady /> </React.Suspense>
}
