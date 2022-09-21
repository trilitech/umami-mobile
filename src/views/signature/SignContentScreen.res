open Paper
open SignUtils

module GenericForm = {
  @react.component
  let make = (~onSubmit) => {
    let (content, setContent) = React.useState(_ => "")
    <Container>
      <InstructionsPanel title="Sign content" instructions="Enter the content you wish to sign" />
      <TextInput
        value=content
        style={ReactNative.Style.style(~height=130.->ReactNative.Style.dp, ())}
        multiline=true
        mode=#outlined
        onChangeText={t => setContent(_ => t)}
      />
      <Button
        disabled={false}
        onPress={_ => {
          onSubmit(content)
        }}
        style={ReactNative.Style.style(~marginVertical=10.->ReactNative.Style.dp, ())}
        mode=#contained>
        <Paper.Text> {React.string("Sign")} </Paper.Text>
      </Button>
    </Container>
  }
}

let renderForm = onSubmit => <GenericForm onSubmit />

@react.component
let make = (~navigation as _, ~route as _) => {
  let sign = useSign()
  let notify = SnackBar.useNotification()
  sign->Helpers.reactFold(sign => <ContentSigner sign notify renderForm />)
}