open Paper

@react.component
let make = (~onSubmit, ~loading=false) => {
  let (value1, setValue1) = React.useState(_ => "")
  let (value2, setValue2) = React.useState(_ => "")
  <>
    <TextInput
      style={FormStyles.styles["verticalMargin"]}
      disabled=loading
      secureTextEntry=true
      placeholder="Passcode"
      value=value1
      label="Passcode"
      mode=#flat
      onChangeText={s => setValue1(_ => s)}
    />
    <TextInput
      style={FormStyles.styles["verticalMargin"]}
      disabled=loading
      secureTextEntry=true
      placeholder="Confirm passcode"
      value=value2
      label="Confirm passcode"
      mode=#flat
      onChangeText={s => setValue2(_ => s)}
    />
    <Button
      loading
      style={FormStyles.styles["verticalMargin"]}
      mode=#contained
      onPress={_ => onSubmit(value1)}>
      {React.string("Submit")}
    </Button>
  </>
}
