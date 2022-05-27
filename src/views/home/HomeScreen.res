open NavStacks.OnBoard

module HomeCoreView = {
  let routes: array<Paper.BottomNavigation.route> = [
    {
      "key": "account",
      "title": "account",
      "icon": "credit-card",
      "color": None,
      "badge": None,
      "accessibilityLabel": None,
      "testID": None,
    },
    {
      "key": "nft",
      "title": "nft",
      "icon": "diamond-stone",
      "color": None,
      "badge": None,
      "accessibilityLabel": None,
      "testID": None,
    },
  ]

  @react.component
  let make = () => {
    let backgroundColor = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.surface

    open Paper
    let (routeIndex, setRouteIndex) = React.useState(() => 0)

    open ReactNative.Style
    let render = account => <>
      <BottomNavigation
        shifting=true
        barStyle={style(~backgroundColor, ~shadowOffset=offset(~height=19., ~width=14.), ())}
        navigationState={{"index": routeIndex, "routes": routes}}
        onIndexChange={i => {
          setRouteIndex(_ => i)
        }}
        renderScene={s => {
          let key = s["route"]["key"]
          switch key {
          | "account" => <Balances account />
          // <DefaultView icon="credit-card" title="Account" subTitle="You have no tez yet..." />
          | "nft" => <Nfts />
          // | "transfer" =>
          //   <DefaultView icon="upload" title="Transfer" subTitle="Transfer tez here..." />
          | _ => React.null
          }
        }}
      />
    </>

    Store.useWithAccount(account => render(account))
  }
}

@react.component
let make = (~navigation, ~route as _) => {
  let navigate = (route, ()) => navigation->Navigation.navigate(route)
  <>
    <TopBar
      onNetworkPress={navigate("ScanQR")}
      onSettingsPress={navigate("Settings")}
      onNotificationPress={navigate("Notifications")}
    />
    <Profile />
    <HomeCoreView />
  </>
}
