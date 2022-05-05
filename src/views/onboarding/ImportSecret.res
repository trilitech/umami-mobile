open Paper

open Store
@react.component
let make = (~navigation as _, ~route as _) => {
  let (_, setSecret) = Store.useAccounts()
  <Background>
    <Caption> {React.string("Recovery phrase")} </Caption>
    <TextInput
      style={ReactNative.Style.style(~height=130.->ReactNative.Style.dp, ())}
      multiline=true
      mode=#outlined
    />
    <Button
      onPress={_ => {
        setSecret(_ => [
          {
            tz1: "foo",
            sk: "bar",
            derivationPathIndex: 9,
            name: "cool",
            balance: None,
          },
        ])
      }}
      style={ReactNative.Style.style(~marginVertical=10.->ReactNative.Style.dp, ())}
      mode=#contained>
      <Paper.Text> {React.string("Continue")} </Paper.Text>
    </Button>
  </Background>
}
