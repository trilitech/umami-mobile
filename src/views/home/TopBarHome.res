open ReactNative
open Style

module UmaminiLogo = {
  @react.component
  let make = () =>
    <Paper.Title
      style={style(
        // ~fontFamily="Montserrat-Regular",
        ~marginHorizontal=16.->dp,
        (),
      )}>
      {React.string("umami")}
    </Paper.Title>
}

module RightMenu = {
  @react.component
  let make = (~onOpenModal as _, ~onGoToSettings) => {
    let color = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.text
    <View style={style(~position=#absolute, ~right=5.->dp, ())}>
      <Paper.Appbar.Action
        color onPress={_ => onGoToSettings()} icon={Paper.Icon.name("cog-outline")}
      />
    </View>
  }
}
@react.component
let make = (~onNetworkPress as _, ~onSettingsPress, ~onNotificationPress) => {
  <TopBarPlain
    left={<UmaminiLogo />}
    right={<RightMenu onOpenModal=onNotificationPress onGoToSettings=onSettingsPress />}
  />
}
