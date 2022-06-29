open CommonComponents

@react.component
let make = (~navigation as _, ~route as _) => {
  let navigate = NavUtils.useNavigate()

  let reset = Store.useReset()
  let dangerColor = ThemeProvider.useErrorColor()

  open Paper
  let makeListItem = (route, label) =>
    <CustomListItem
      onPress={_ => navigate(route)->ignore}
      center={<Text> {React.string(label)} </Text>}
      right={<CommonComponents.Icon name="chevron-right" />}
    />

  <Container>
    {makeListItem("Theme", "Theme")}
    {makeListItem("Contacts", "Contacts")}
    {makeListItem("Network", "Network")}
    {makeListItem("BackupPhrase", "Show backup phrase")}
    <List.Section title="Storage">
      <Button mode=#contained onPress={_ => reset()} color=dangerColor>
        <Text> {React.string("Erase secret")} </Text>
      </Button>
    </List.Section>
    <Version />
  </Container>
}
