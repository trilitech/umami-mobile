open ReactNative
open ReactNative.Style

@react.component
let make = (~children) => {
  open Paper.ThemeProvider
  let theme = useTheme()
  let backgroundColor = Theme.colors(theme)->Theme.Colors.background
  // flex=1 for full height
  <View style={style(~backgroundColor, ~flex=1., ~padding=10.->dp, ())}> {children} </View>
}
