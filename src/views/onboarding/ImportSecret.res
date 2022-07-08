open Paper

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
      <Caption> {React.string("Recovery phrase")} </Caption>
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

@react.component
let make = (~navigation as _, ~route as _) => {
  let (dangerousText, setDangerousText) = EphemeralState.useEphemeralState("")

  let (_, dispatch) = AccountsReducer.useAccountsDispatcher()
  let notify = SnackBar.useNotification()

  let (loading, setLoading) = React.useState(_ => false)

  let hoc = (~onSubmit) => <ImportSecret dangerousText setDangerousText onSubmit />

  let handleAccounts = (accounts: array<Account.t>, password) => {
    if accounts == [] {
      notify("No accounts revealed for this secret...")
    } else {
      AESCrypto.encrypt(dangerousText, password)
      ->Promise.thenResolve(_ => ReplaceAll(accounts)->dispatch)
      ->ignore
    }
  }
  let onConfirm = password => {
    setLoading(_ => true)
    AccountUtils.restoreKeys(
      ~mnemonic=dangerousText->formatForMnemonic,
      ~password,
      ~onDone=accounts => {
        switch accounts {
        | Ok(accounts) =>
          handleAccounts(accounts->Belt.Array.map(AccountUtils.keysToAccount), password)
        | Error(_) => ()
        }

        setLoading(_ => false)
      },
      (),
    )
  }

  let element = UsePassphraseConfirm.usePassphraseConfirm(
    ~hoc,
    ~onConfirm,
    ~creation=true,
    ~isLoading=loading,
    (),
  )
  <Container> {element} </Container>
}
