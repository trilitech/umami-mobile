open CommonComponents

open Paper

open Theme
@react.component
let make = (~navigation as _, ~route as _) => {
  let (theme, setTheme) = Store.useTheme()

  let makeRadio = value =>
    <LabeledRadio
      onPress={_ => setTheme(_ => value)}
      label={Theme.toString(value)}
      status={theme == value ? #checked : #unchecked}
      value={Theme.toString(value)}
    />
  <Container>
    <List.Section title="Theme">
      {makeRadio(Dark)} {makeRadio(Light)} {makeRadio(System)}
    </List.Section>
  </Container>
}
