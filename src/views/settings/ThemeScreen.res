open CommonComponents

open Paper

@react.component
let make = (~navigation as _, ~route as _) => {
  let (theme, setTheme) = Store.useTheme()

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
  </Container>
}
