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
  // {
  //   "key": "transfer",
  //   "title": "transfer",
  //   "icon": "upload",
  //   "color": None,
  //   "badge": None,
  //   "accessibilityLabel": None,
  //   "testID": None,
  // },
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
let make = (~onSendPress, ~onAccountsPress) => {
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
        | "account" => <Balances account onAccountsPress onPressSend=onSendPress />
        // <DefaultView icon="credit-card" title="Account" subTitle="You have no tez yet..." />
        | "nft" =>
          <DefaultView icon="diamond-stone" title="NFT" subTitle="You have no nfts yet..." />
        // | "transfer" =>
        //   <DefaultView icon="upload" title="Transfer" subTitle="Transfer tez here..." />
        | _ => React.null
        }
      }}
    />
  </>

  let account = Store.useActiveAccount()
  switch account {
  | Some(account) => render(account)
  | None => React.null
  }
}
