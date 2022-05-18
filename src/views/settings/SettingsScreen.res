open CommonComponents

open Paper
@react.component
let make = (~navigation as _, ~route as _) => {
  let (theme, setTheme) = Store.useTheme()

  let reset = Store.useResetAccounts()
  let makeRadio = value =>
    <LabeledRadio
      onPress={_ => setTheme(value)}
      label=value
      status={theme == value ? #checked : #unchecked}
      value
    />

  <Container>
    <List.Section title="Theme">
      {makeRadio("dark")} {makeRadio("light")} {makeRadio("system")}
    </List.Section>
    <List.Section title="Storage">
      <Button mode=#contained onPress={_ => reset()}>
        <Paper.Text> {React.string("Erase secret")} </Paper.Text>
      </Button>
    </List.Section>
    <Version />
  </Container>
}
