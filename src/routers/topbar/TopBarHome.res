module UmaminiLogo = {
  @react.component
  let make = () =>
    <Paper.Title style={StyleUtils.makeLeftMargin(~size=2, ())}>
      {React.string("umami")}
    </Paper.Title>
}

@react.component
let make = (~onNetworkPress as _, ~onSettingsPress, ~onNotificationPress as _) => {
  <TopBarPlain
    left={<UmaminiLogo />}
    right={<RightLogoForTopBar onPressLogo=onSettingsPress logoName="cog-outline" />}
  />
}
