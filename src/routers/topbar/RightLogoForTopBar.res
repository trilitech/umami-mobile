open ReactNative
open Style
@react.component
let make = (~onPressLogo, ~logoName) => {
  let color = ThemeProvider.useTextColor()
  <View style={style(~position=#absolute, ~right=8.->dp, ())}>
    <Paper.Appbar.Action color onPress={_ => onPressLogo()} icon={Paper.Icon.name(logoName)} />
  </View>
}
