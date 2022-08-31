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
          | "nft" => <Nfts />
          | _ => React.null
          }
        }}
      />
    </>

    Store.useWithAccount(account => render(account))
  }
}

let data = `
{
  "version": "1.0",
  "derivationPath": 
    "m/44'/1729'/?'/0'"
  ,
  "recoveryPhrase": 
    {
      "salt": "467bb56d02ade5e7005d8e2ad59e9ce8d863da6edb2880de4bd6549140d3e422",
      "iv": "7b34cdbfa79a753d2ce393caea78c9f8",
      "data": "ed09930881d0787aae686fccd600a5f393752e487c6b01f02c60a4b0a4864f27543b4fc7e6ef6171c799466083c1c61ac0a8eaa9fc0bd538be671c5b2d0cd4ff2a30c6a49f2de84c7544d4f21ff0ed9f0598acbba65791da685b73e6ca498de8fa050de0b2f48adf5c67a6033c27cccbaf285f3ac24ebe4c40c5df2a1eadbc67ba47d919ad48c9a71dd653226a33957c0430c208d79ea907e1e1877c54c4bc46d612b3abf96243d62f1d90ff"
    }
  
}

`
@react.component
let make = (~navigation, ~route as _) => {
  let navigate = (route, ()) => navigation->Navigation.navigate(route)

  let (receiveDrawer, _, open_) = BottomSheet.useBottomSheet(
    ~element=_ => <ReceiveAssetsPanel />,
    (),
  )
  <>
    <TopBarHome
      onNetworkPress={navigate("ScanQR")}
      onSettingsPress={navigate("Settings")}
      onNotificationPress={navigate("Notifications")}
    />
    <Profile onPressReceive={_ => open_()} />
    <Qr value=data size=300 />
    {receiveDrawer}
  </>
}
