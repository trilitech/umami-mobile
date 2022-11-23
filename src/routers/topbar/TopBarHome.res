@react.component
let make = (~onNetworkPress as _, ~onSettingsPress, ~onNotificationPress as _) => {
  <TopBarAllScreens.TopBarPlain
    left={<UmamiBarTitle />}
    right={<RightLogoForTopBar onPressLogo=onSettingsPress logoName="cog-outline" />}
  />
}
