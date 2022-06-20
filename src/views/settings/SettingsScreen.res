open CommonComponents

open Paper
@react.component
let make = (~navigation as _, ~route as _) => {
  let (theme, setTheme) = Store.useTheme()
  let navigate = NavUtils.useNavigate()

  let reset = Store.useResetAccounts()
  let makeRadio = value =>
    <LabeledRadio
      onPress={_ => setTheme(_ => value)}
      label=value
      status={theme == value ? #checked : #unchecked}
      value
    />

  <Container>
    <List.Section title="Theme">
      {makeRadio("dark")} {makeRadio("light")} {makeRadio("system")}
    </List.Section>
    <CustomListItem
      onPress={_ => navigate("Contacts")->ignore}
      center={<Text> {React.string("Contacts")} </Text>}
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
