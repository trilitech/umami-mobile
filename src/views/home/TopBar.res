open ReactNative
open Style

module UmaminiLogo = {
  @react.component
  let make = () => {
    let primary = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.primary
    <>
      <Paper.Text
        style={style(~fontFamily="Montserrat-Regular", ~fontWeight=#_600, ~fontSize=20., ())}>
        {React.string("uma")}
      </Paper.Text>
      <Paper.Text
        style={style(
          ~fontFamily="Montserrat-Regular",
          ~fontWeight=#_600,
          ~fontSize=20.,
          ~color=primary,
          (),
        )}>
        {React.string("mini")}
      </Paper.Text>
    </>
  }
}

module RightMenu = {
  @react.component
  let make = (~onOpenModal as _, ~onGoToSettings) => {
    let color = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.text
    <View style={style(~display=#flex, ~flexDirection=#row, ())}>
      // <Appbar.Action icon={Icon.name("account")} />
      // <Appbar.Action onPress={_ => onOpenModal()} icon={Icon.name("bell-badge")} />
      <Paper.Appbar.Action
        color onPress={_ => onGoToSettings()} icon={Paper.Icon.name("cog-outline")}
      />
    </View>
  }
}
module LeftMenu = {
  @react.component
  let make = (~onPress) => {
    <TouchableOpacity onPress={_ => onPress()}>
      <View
        style={style(
          ~display=#flex,
          ~flexDirection=#row,
          ~alignItems=#center,
          ~marginLeft=5.->dp,
          (),
        )}>
        <UmaminiLogo />
      </View>
    </TouchableOpacity>
  }
}

@react.component
let make = (~onNetworkPress, ~onSettingsPress, ~onNotificationPress) => {
  let backgroundColor = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.surface
  let borderBottomColor = ThemeProvider.useColors()->Paper.ThemeProvider.Theme.Colors.background
  open Paper
  <Appbar.Header
    style={style(
      ~display=#flex,
      ~justifyContent=#spaceBetween,
      ~backgroundColor,
      ~borderBottomColor,
      ~borderBottomWidth=1.,
      (),
    )}>
    <LeftMenu onPress=onNetworkPress />
    <RightMenu onOpenModal=onNotificationPress onGoToSettings=onSettingsPress />
  </Appbar.Header>
}
