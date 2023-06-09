open CommonComponents
open NavStacks.OffBoard

open ReactNative.Style

@react.component
let make = (~navigation, ~route as _) => {
  <Container>
    <ReactNative.View
      style={style(~display=#flex, ~flexDirection=#row, ~justifyContent=#center, ())}>
      <UmamiLogo size=70. style={style(~margin=30.->dp, ())} />
    </ReactNative.View>
    <ListItem
      onPress={_ => navigation->Navigation.navigate("NewSecret")}
      title="Create new secret"
      iconName="plus"
    />
    <ListItem
      onPress={_ => navigation->Navigation.navigate("ImportSecret")}
      title="Import secret with recovery phrase"
      iconName="format-list-bulleted"
    />
    <ListItem
      onPress={_ => navigation->Navigation.navigate("QRImportInstructions")}
      title="Import secret with Umami Desktop QR code"
      iconName="qrcode-scan"
    />
    // <ListItem
    //   onPress={_ => navigation->Navigation.navigate("ImportSecret")}
    //   title="Restore from backtup"
    //   iconName="cloud-download-outline"
    // />
    // <ListItem
    //   onPress={_ => navigation->Navigation.navigate("ImportSecret")}
    //   title="Connect with google"
    //   iconName="google"
    // />
    // <ListItem
    //   onPress={_ => navigation->Navigation.navigate("ImportSecret")}
    //   title="Connect with twitter"
    //   iconName="twitter"
    //   iconColor="#00acee"
    // />
    <Version />
  </Container>
}
