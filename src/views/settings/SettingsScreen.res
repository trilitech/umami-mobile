open CommonComponents
open Paper
module PrivacyPolicy = {
  @react.component
  let make = () => {
    let url = "https://umamiwallet.com/tos.html"
    <CustomListItem
      onPress={_ => ReactNative.Linking.openURL(url)->ignore}
      center={<Text> {React.string("Privacy policy")} </Text>}
      right={<CommonComponents.Icon name="open-in-new" />}
    />
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let navigate = NavUtils.useNavigate()

  let makeListItem = (route, label) =>
    <CustomListItem
      height=#small
      onPress={_ => navigate(route)->ignore}
      center={<Text> {React.string(label)} </Text>}
      right={<ChevronRight />}
    />

  <ReactNative.ScrollView>
    <Container>
      {makeListItem("Theme", "Theme")}
      {makeListItem("Contacts", "Contacts")}
      {makeListItem("Dapps", "Dapps")}
      {makeListItem("Network", "Network")}
      {makeListItem("ChangePassword", "Change Password")}
      {makeListItem("BackupPhrase", "Show backup phrase")}
      {makeListItem("Biometrics", "Biometrics")}
      {makeListItem("Logs", "Logs")}
      {makeListItem("OffboardWallet", "Offboard Wallet")}
      {makeListItem("ScanSignedContent", "Verify Signature")}
      {makeListItem("SignContent", "Sign Content")}
      <PrivacyPolicy />
      <Version />
    </Container>
  </ReactNative.ScrollView>
}
