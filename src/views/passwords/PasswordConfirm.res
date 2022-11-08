open Paper

let vMargin = StyleUtils.makeVMargin()
let isMinLength = pwd => pwd->Js.String2.length > 3

let defaultHeader = <Title> {React.string("Enter password to continue")} </Title>

module Plain = {
  @react.component
  let make = (~onSubmit, ~loading=false, ~label="submit") => {
    let (value, setValue) = EphemeralState.useEphemeralState("")
    <>
      <TextInput
        testID="password"
        disabled=loading
        secureTextEntry=true
        placeholder="Enter password"
        value
        label="Password"
        mode=#outlined
        onChangeText={t => setValue(_ => t)}
        style=vMargin
      />
      <Button
        disabled={!isMinLength(value) || loading}
        loading
        style={vMargin}
        mode=#contained
        onPress={_ => onSubmit(value)}>
        {React.string(label)}
      </Button>
    </>
  }
}

@react.component
let make = (~onSubmit, ~loading=false) => {
  <> {defaultHeader} <Plain onSubmit loading /> </>
}
