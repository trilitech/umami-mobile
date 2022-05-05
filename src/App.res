// include ReactNativeHelloWorldUtils

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
module MemoizedRouter = {
  open ReactNavigation
  @react.component
  let make = React.memo((~hasAccount) => {
    <Native.NavigationContainer>
      {hasAccount ? <OnboardRouter /> : <OffboardRouter />}
    </Native.NavigationContainer>
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
      <ThemeProvider>
        {storeIsUpToDate ? <SnackbarDisplayer> <Router /> </SnackbarDisplayer> : React.null}
      </ThemeProvider>
    </ReactQuery.Provider>
  })
}

@react.component
let app = () => {
  let storeIsUpToDate = Store.useInit()

  // Prevent rerenders sinces useInit is hook to all the states

  <MemoizedApp storeIsUpToDate />
}

// smoke test library import
// Js.Console.log("lib import works look: " ++ UmamiLibBindings.Hello.foo)
