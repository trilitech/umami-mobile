%%raw(`
require('./ignoreWarnings')
`)

// TODO refactor all this init boilerplate code
let useLogInit = () => {
  let (ready, setReady) = React.useState(_ => false)
  let notify = SnackBar.useNotification()

  React.useEffect2(() => {
    Logger.init()
    ->Promise.thenResolve(_ => setReady(_ => true))
    ->Promise.catch(exn => {
      notify("Failed to initialize logger." ++ exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore
    None
  }, (notify, setReady))
  ready
}

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
        // Allow scrollin if screen ever overflows (which should not happen on any device)
        <ReactNative.ScrollView contentContainerStyle={ReactNative.Style.style(~flex=1., ())}>
          {hasAccount ? <OnboardRouter /> : <OffboardRouter />}
        </ReactNative.ScrollView>
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
      <ThemeProvider> {allReady ? <Router /> : React.null} </ThemeProvider>
    </ReactQuery.Provider>
  })
}

@react.component
let app = () => {
  let storeIsUpToDate = StoreInit.useInit()
  let loggerIsReady = useLogInit()
  let allReady = storeIsUpToDate && loggerIsReady

  // Prevent rerenders sinces useInit is hooked to all the states
  <MemoizedApp allReady />
}
