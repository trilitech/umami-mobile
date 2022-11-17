open Paper

let vMargin = StyleUtils.makeVMargin()
let isMinLength = pwd => pwd->Js.String2.length > 3

let defaultHeader = <Title> {React.string("Enter password to continue")} </Title>

module Plain = {
  @react.component
  let make = (~onSubmit, ~loading=false, ~label="submit", ~disabled=false) => {
    let (value, setValue) = EphemeralState.useEphemeralState("")
    <>
      <UI.Input
        testID="password"
        disabled=loading
        secureTextEntry=true
        placeholder="Enter password"
        value
        label="Password"
        onChangeText={t => setValue(_ => t)}
        style=vMargin
      />
      <Button
        disabled={!isMinLength(value) || loading || disabled}
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
let make = (~onSubmit, ~loading=false, ~disabled=?) => {
  <> {defaultHeader} <Plain onSubmit loading ?disabled /> </>
}
