open ReactNative.Style
open UmamiThemeProvider
@react.component
let make = (~route, ~navigation as _) => {
  let url = NavUtils.getBrowserUrl(route)
  let backgroundColor = useBgColor()

  url->Helpers.reactFold(url => <RNWebView style={style(~backgroundColor, ())} source={uri: url} />)
}
