open Paper

let vMargin = StyleUtils.makeVMargin()

@react.component
let make = (~onSubmit, ~loading=false) => {
  let (value, setValue) = EphemeralState.useEphemeralState("")
  <>
    <Title> {React.string("Enter password to continue")} </Title>
    <TextInput
      disabled=loading
      secureTextEntry=true
      placeholder="password"
      value
      label="passphrase"
      mode=#flat
      onChangeText={t => setValue(_ => t)}
      style=vMargin
    />
    <Button
      disabled={!PasswordUtils.isMinLength(value) || loading}
      loading
      style={vMargin}
      mode=#contained
      onPress={_ => onSubmit(value)}>
      {React.string("Submit")}
    </Button>
  </>
}
