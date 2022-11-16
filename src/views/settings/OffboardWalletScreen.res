open CommonComponents
open StyleUtils

let confirmationCode = "wasabi"

let offbardText = `Offboarding will permanently delete any data from this device. Please acknowledge that you have read and understood the disclaimer, then enter ${confirmationCode} to confirm. The accounts are still available to be imported in the future ; in order to regain access to your accounts, please make sure that you keep the recovery phrase.`
let confirmTextLabel = "I have read the warning and I am certain I want to delete my private keys locally. I also made sure to keep my recovery phrase."

let formIsValid = (providedCode, checked) =>
  providedCode->Js.String2.toLowerCase == confirmationCode && checked == #checked

@react.component
let make = (~navigation as _, ~route as _) => {
  let dangerColor = UmamiThemeProvider.useErrorColor()
  let (confirmText, setConfirmText) = React.useState(_ => "")
  let (status, setStatus) = React.useState(_ => #unchecked)
  let (loading, setLoading) = React.useState(_ => false)
  let setPassword = Biometrics.useKeychainStorage()
  let reset = Store.useReset()
  let notify = SnackBar.useNotification()

  open Paper
  <Container>
    <InstructionsPanel instructions=offbardText danger=true />
    <CheckBoxAndText status setStatus text=confirmTextLabel />
    <TextInput
      style={makeVMargin()}
      placeholder="Enter code word"
      label="Code word"
      value=confirmText
      mode=#outlined
      onChangeText={t => setConfirmText(_ => t)}
    />
    <Button
      style={makeVMargin()}
      loading
      disabled={!formIsValid(confirmText, status) || loading}
      mode=#contained
      onPress={_ => {
        setLoading(_ => true)
        setPassword(None)
        ->Promise.then(_ => {
          DerivationPath.erase()
          ->Promise.then(BackupPhraseStorage.erase)
          ->Promise.catch(exn => {
            setLoading(_ => false)
            notify("Offboarding failed" ++ Helpers.getMessage(exn))
            Promise.resolve()
          })
          ->Promise.thenResolve(_ => {
            reset()
          })
        })
        ->ignore
      }}
      color=dangerColor>
      <Text> {React.string("Erase secret")} </Text>
    </Button>
  </Container>
}
