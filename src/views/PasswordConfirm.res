open Paper

let vMargin = FormStyles.styles["verticalMargin"]
module PurePasswordConfirm = {
  @react.component
  let make = (~value, ~onChange) => {
    <>
      <Headline> {React.string("Enter password to continue")} </Headline>
      <TextInput
        secureTextEntry=true
        placeholder="password"
        value
        label="passphrase"
        mode=#flat
        onChangeText={onChange}
        style=vMargin
      />
    </>
  }
}

@react.component
let make = (~onSubmit) => {
  let (value, setValue) = React.useState(_ => "")
  <>
    <PurePasswordConfirm value onChange={t => setValue(_ => t)} />
    <Button style={vMargin} mode=#contained onPress={_ => onSubmit(value)}>
      {React.string("Submit")}
    </Button>
  </>
}
