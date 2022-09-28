open ReactNative
open Style
@react.component
let make = (~onPressLogo, ~logoName, ~disabled=false) => {
  let color = UmamiThemeProvider.useTextColor()
  <View style={style(~position=#absolute, ~right=8.->dp, ())}>
    <Paper.Appbar.Action
      disabled color onPress={_ => onPressLogo()} icon={Paper.Icon.name(logoName)}
    />
  </View>
}
