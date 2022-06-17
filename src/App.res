%%raw(`
require('./ignoreWarnings')
`)

// let useIsDarkMode = () => {
//   Appearance.useColorScheme()
//   ->Js.Null.toOption
//   ->Belt.Option.map(scheme => scheme === #dark)
//   ->Belt.Option.getWithDefault(false)
// }

let useHasAccount = () => {
  let (accounts, _) = Store.useAccounts()
  let account = accounts->Belt.Array.get(0)
  Belt.Option.isSome(account)
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
        {hasAccount ? <OnboardRouter /> : <OffboardRouter />}
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
  let make = React.memo((~storeIsUpToDate) => {
    <ReactQuery.Provider client>
      <ThemeProvider> {storeIsUpToDate ? <Router /> : React.null} </ThemeProvider>
    </ReactQuery.Provider>
  })
}

@react.component
let app = () => {
  let storeIsUpToDate = StoreInit.useInit()

  // Prevent rerenders sinces useInit is hooked to all the states

  <MemoizedApp storeIsUpToDate />
}

// smoke test library import
// Js.Console.log("lib import works look: " ++ UmamiLibBindings.Hello.foo)
