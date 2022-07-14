open Paper

let vMargin = StyleUtils.makeVMargin()
let isMinLength = pwd => pwd->Js.String2.length > 3

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
      label="password"
      mode=#flat
      onChangeText={t => setValue(_ => t)}
      style=vMargin
    />
    <Button
      disabled={!isMinLength(value) || loading}
      loading
      style={vMargin}
      mode=#contained
      onPress={_ => onSubmit(value)}>
      {React.string("Submit")}
    </Button>
  </>
}
