open CommonComponents

@react.component
let make = (~navigation as _, ~route as _) => {
  let navigate = NavUtils.useNavigate()

  open Paper
  let makeListItem = (route, label) =>
    <CustomListItem
      onPress={_ => navigate(route)->ignore}
      center={<Text> {React.string(label)} </Text>}
      right={<ChevronRight />}
    />

  <Container>
    {makeListItem("Theme", "Theme")}
    {makeListItem("Contacts", "Contacts")}
    {makeListItem("Network", "Network")}
    {makeListItem("ChangePassword", "Change Password")}
    {makeListItem("BackupPhrase", "Show backup phrase")}
    {makeListItem("OffboardWallet", "Offboard Wallet")}
    <Version />
  </Container>
}
