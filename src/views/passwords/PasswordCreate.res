open Paper
open CommonComponents
open Belt

%%private(
  // Regex enforces the following:
  // "Password must contain one digit from 1 to 9, one lowercase letter, one uppercase letter, one special character, no space, and it must be 8-16 characters long."
  let passwordRegex = %re("/^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,16}$/")

  let pwdIsValid = str => passwordRegex->Js.Re.test_(str)

  let getError = (str1, str2) =>
    if !pwdIsValid(str1) {
      #passwordTooShort->Some
    } else if str1 != str2 {
      #passwordsDontMatch->Some
    } else {
      None
    }

  let getErrorName = err =>
    switch err {
    | #passwordTooShort => "Password must contain one digit from 1 to 9, one lowercase letter, one uppercase letter, one special character, no space, and it must be 8-16 characters long."
    | #passwordsDontMatch => "Passwords don't match!"
    }
)

@react.component
let make = (~onSubmit, ~loading=false) => {
  let (value1, setValue1) = EphemeralState.useEphemeralState("")
  let (value2, setValue2) = EphemeralState.useEphemeralState("")
  let (status, setStatus) = React.useState(_ => #unchecked)
  let empty = value1 === "" && value2 === ""

  let (bio, setBio) = React.useState(_ => true)

  let error = empty ? None : getError(value1, value2)
  <>
    <Title> {React.string("Enter and confirm password")} </Title>
    <UI.Input
      error={error->Option.isSome}
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="Password"
      value=value1
      label="Password"
      onChangeText={s => setValue1(_ => s)}
    />
    <UI.Input
      error={error->Option.isSome}
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="Confirm password"
      value=value2
      label="Confirm password"
      onChangeText={s => setValue2(_ => s)}
    />
    <HelperText _type=#error visible={error->Option.isSome}>
      {error->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>
    <Biometrics.BiometricsSwitch onChange={_ => setBio(val => !val)} biometricsEnabled=bio />
    <CheckBoxAndText
      status setStatus text="I understand that Umami cannot recover this password for me."
    />
    <Button
      disabled={error->Option.isSome || loading || empty || status == #unchecked}
      loading
      style={StyleUtils.makeVMargin()}
      mode=#contained
      onPress={_ => onSubmit({"password": value1, "saveInKeyChain": bio})}>
      {React.string("Submit")}
    </Button>
  </>
}
