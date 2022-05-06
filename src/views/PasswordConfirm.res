open Paper

let vMargin = FormStyles.styles["verticalMargin"]
module PurePasswordConfirm = {
  @react.component
  let make = (~value, ~onChange, ~loading) => {
    <>
      <Headline> {React.string("Enter password to continue")} </Headline>
      <TextInput
        disabled=loading
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
let make = (~onSubmit, ~loading) => {
  let (value, setValue) = React.useState(_ => "")
  <>
    <PurePasswordConfirm loading value onChange={t => setValue(_ => t)} />
    <Button loading style={vMargin} mode=#contained onPress={_ => onSubmit(value)}>
      {React.string("Submit")}
    </Button>
  </>
}
