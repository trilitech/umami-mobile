open Paper

let formValid = (s1: string, s2: string) => {
  s1 == s2 && s1->PasswordUtils.isMinLength
}

@react.component
let make = (~onSubmit, ~loading=false) => {
  let (value1, setValue1) = EphemeralState.useEphemeralState("")
  let (value2, setValue2) = EphemeralState.useEphemeralState("")
  <>
    <Title> {React.string("Enter and confirm password")} </Title>
    <TextInput
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="Passcode"
      value=value1
      label="Passcode"
      mode=#flat
      onChangeText={s => setValue1(_ => s)}
    />
    <TextInput
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="Confirm passcode"
      value=value2
      label="Confirm passcode"
      mode=#flat
      onChangeText={s => setValue2(_ => s)}
    />
    <Button
      disabled={!formValid(value1, value2) || loading}
      loading
      style={StyleUtils.makeVMargin()}
      mode=#contained
      onPress={_ => onSubmit(value1)}>
      {React.string("Submit")}
    </Button>
  </>
}
