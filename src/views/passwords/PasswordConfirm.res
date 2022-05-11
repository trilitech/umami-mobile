open Paper

let vMargin = FormStyles.styles["verticalMargin"]

@react.component
let make = (~onSubmit, ~loading=false) => {
  let (value, setValue) = React.useState(_ => "")
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
    <Button loading style={vMargin} mode=#contained onPress={_ => onSubmit(value)}>
      {React.string("Submit")}
    </Button>
  </>
}
