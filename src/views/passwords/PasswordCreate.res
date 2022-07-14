open Paper
open Belt

%%private(
  // Regex enforces the following:
  // "Password must contain one digit from 1 to 9, one lowercase letter, one uppercase letter, one special character, no space, and it must be 8-16 characters long."
  let passwordRegex = %re("/^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*\W)(?!.* ).{8,16}$/")

  let pwdIsValid = str => passwordRegex->Js.Re.test_(str)

  let useformIsPristine = (v1, v2) => {
    open FormValidators
    let p1 = useIsPristine(v1)
    let p2 = useIsPristine(v2)
    p1 && p2
  }

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
  let pristine = useformIsPristine(value1, value2)

  let error = pristine ? None : getError(value1, value2)
  <>
    <Title> {React.string("Enter and confirm password")} </Title>
    <TextInput
      error={error->Option.isSome}
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="password"
      value=value1
      label="password"
      mode=#flat
      onChangeText={s => setValue1(_ => s)}
    />
    <TextInput
      error={error->Option.isSome}
      style={StyleUtils.makeVMargin()}
      disabled=loading
      secureTextEntry=true
      placeholder="Confirm password"
      value=value2
      label="Confirm password"
      mode=#flat
      onChangeText={s => setValue2(_ => s)}
    />
    <HelperText _type=#error visible={error->Option.isSome}>
      {error->Option.mapWithDefault("", getErrorName)->React.string}
    </HelperText>
    <Button
      disabled={error->Option.isSome || loading || pristine}
      loading
      style={StyleUtils.makeVMargin()}
      mode=#contained
      onPress={_ => onSubmit(value1)}>
      {React.string("Submit")}
    </Button>
  </>
}
