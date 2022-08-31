open Paper
open Belt

let formatForMnemonic = (s: string) => {
  s
  ->Js.String2.trim
  ->Js.String2.replaceByRe(%re("/\\n+/"), "")
  ->Js.String2.replaceByRe(%re("/\s+/g"), " ")
}

let inputIsValid = (s: string) => s->formatForMnemonic->AccountUtils.backupPhraseIsValid

module ImportSecret = {
  @react.component
  let make = (~onSubmit, ~dangerousText, ~setDangerousText) => {
    <Container>
      <InstructionsPanel
        title="Enter your recovery phrase"
        instructions="Please fill in the recovery phrase in sequence.
Umami supports 12-, 15-, 18-, 21- and 24-word recovery phrases."
      />
      <TextInput
        value=dangerousText
        style={ReactNative.Style.style(~height=130.->ReactNative.Style.dp, ())}
        multiline=true
        mode=#outlined
        onChangeText={t => setDangerousText(_ => t)}
      />
      <Button
        disabled={!inputIsValid(dangerousText)}
        onPress={_ => {
          onSubmit(dangerousText)
        }}
        style={ReactNative.Style.style(~marginVertical=10.->ReactNative.Style.dp, ())}
        mode=#contained>
        <Paper.Text> {React.string("Continue")} </Paper.Text>
      </Button>
    </Container>
  }
}

let restoreAndSave = (~dangerousText, ~password, ~notify, ~dispatch) => {
  open AccountsReducer
  let mnemonic = dangerousText->formatForMnemonic

  BackupPhraseStorage.save(mnemonic, password)
  ->Promise.then(_ => AccountUtils.restoreKeysPromise(~mnemonic, ~password))
  ->Promise.thenResolve(keys => {
    let accounts = keys->Array.map(AccountUtils.keysToAccount)
    if accounts == [] {
      Js.Exn.raiseError("No accounts revealed for this secret...")
    } else {
      AESCrypto.encrypt(mnemonic, password)
      ->Promise.thenResolve(_ => ReplaceAll(accounts)->dispatch)
      ->ignore
    }
  })
  ->Promise.thenResolve(_ => notify("Successfully restored accounts!"))
  ->Promise.catch(exn => {
    notify("Failed to restore accounts. " ++ exn->Helpers.getMessage)
    Promise.resolve()
  })
}

let useRestoreAndSave = () => {
  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()
  let notify = SnackBar.useNotification()
  restoreAndSave(~dispatch, ~notify)
}
@react.component
let make = (~navigation as _, ~route as _) => {
  let (dangerousText, setDangerousText) = EphemeralState.useEphemeralState("")

  let (loading, setLoading) = React.useState(_ => false)

  let hoc = (~onSubmit) => <ImportSecret dangerousText setDangerousText onSubmit />

  let restoreAndSave = useRestoreAndSave()

  let onConfirm = password => {
    setLoading(_ => true)
    restoreAndSave(~password, ~dangerousText)->Promise.finally(_ => setLoading(_ => false))->ignore
  }

  let element = UsePasswordConfirm.usePasswordConfirm(
    ~hoc,
    ~onConfirm,
    ~creation=true,
    ~loading,
    (),
  )
  <Container> {element} </Container>
}
