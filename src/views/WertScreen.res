open StyleUtils
open ReactNative.Style
open Paper
open UmamiThemeProvider
@react.component
let make = (~route as _, ~navigation as _) => {
  let dangerColor = useErrorColor()
  let backgroundColor = useBgColor()
  let effectiveTheme = useEffectiveTheme()
  let themeStr = effectiveTheme == #dark ? "dark" : "light"

  Store.useWithAccount(account => {
    let wertUrl = `https://widget.wert.io/default/widget/?address=${account.tz1->Pkh.toString}&commodity=XTZ%3ATezos&commodities=XTZ%3ATezos&theme=${themeStr}`
    <>
      <Text style={array([style(~color=dangerColor, ()), makePadding(~size=3, ())])}>
        {`Notice: you are using Wert, which is an external service to Umami.`->React.string}
      </Text>
      <RNWebView style={style(~backgroundColor, ())} source={uri: wertUrl} />
    </>
  })
}
