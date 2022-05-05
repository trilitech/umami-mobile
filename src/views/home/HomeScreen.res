open NavStacks.OnBoard

@react.component
let make = (~navigation, ~route as _) => {
  let navigate = (route, ()) => navigation->Navigation.navigate(route)
  <>
    <TopBar
      onNetworkPress={navigate("Network")}
      onSettingsPress={navigate("Settings")}
      onNotificationPress={navigate("Notifications")}
    />
    <HomeCoreView onSendPress={navigate("Send")} onAccountsPress={navigate("Accounts")} />
  </>
}
