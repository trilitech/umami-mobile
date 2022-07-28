open StyleUtils
open ReactNative.Style
@react.component
let make = (~route as _, ~navigation as _) => {
  let dangerColor = ThemeProvider.useErrorColor()
  let backgroundColor = ThemeProvider.useBgColor()
  open Paper

  let (theme, _) = Store.useTheme()
  Store.useWithAccount(account => {
    let wertUrl = `https://widget.wert.io/default/widget/?address=${account.tz1}&commodity=XTZ%3ATezos&commodities=XTZ%3ATezos&theme=${theme}`
    <>
      <Text style={array([style(~color=dangerColor, ()), makePadding(~size=3, ())])}>
        {`Notice: you are using Wert, which is an external service to Umami.`->React.string}
      </Text>
      <RNWebView style={style(~backgroundColor, ())} source={uri: wertUrl} />
    </>
  })
}