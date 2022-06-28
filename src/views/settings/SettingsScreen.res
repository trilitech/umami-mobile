open CommonComponents

open Paper
@react.component
let make = (~navigation as _, ~route as _) => {
  let navigate = NavUtils.useNavigate()

  let reset = Store.useReset()

  <Container>
    <CustomListItem
      onPress={_ => navigate("Theme")->ignore}
      center={<Text> {React.string("Theme")} </Text>}
      right={<CommonComponents.Icon name="chevron-right" />}
    />
    <CustomListItem
      onPress={_ => navigate("Contacts")->ignore}
      center={<Text> {React.string("Contacts")} </Text>}
      right={<CommonComponents.Icon name="chevron-right" />}
    />
    <CustomListItem
      onPress={_ => navigate("Network")->ignore}
      center={<Text> {React.string("Network")} </Text>}
      right={<CommonComponents.Icon name="chevron-right" />}
    />
    <List.Section title="Storage">
      <Button mode=#contained onPress={_ => reset()}>
        <Paper.Text> {React.string("Erase secret")} </Paper.Text>
      </Button>
    </List.Section>
    <Version />
  </Container>
}
