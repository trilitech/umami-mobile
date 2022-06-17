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
  let make = (~onSubmit, ~backupPhrase, ~setBackupPhrase) => {
    <Container>
      <Caption> {React.string("Recovery phrase")} </Caption>
      <TextInput
        value=backupPhrase
        style={ReactNative.Style.style(~height=130.->ReactNative.Style.dp, ())}
        multiline=true
        mode=#outlined
        onChangeText={t => setBackupPhrase(_ => t)}
      />
      <Button
        disabled={!inputIsValid(backupPhrase)}
        onPress={_ => {
          onSubmit(backupPhrase)
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
  let (backupPhrase, setBackupPhrase) = React.useState(_ => "")
  let (_, setAccounts) = Store.useAccounts()
  let notify = SnackBar.useNotification()

  let (loading, setLoading) = React.useState(_ => false)
  let hoc = (~onSubmit) => <ImportSecret backupPhrase setBackupPhrase onSubmit />

  let handleAccounts = (accounts: array<Account.t>, passphrase) => {
    if accounts == [] {
      notify("No accounts revealed for this secret...")
    } else {
      BackupphraseCrypto.encrypt(backupPhrase, passphrase)
      ->Promise.thenResolve(_ => {
        setAccounts(_ => accounts)
      })
      ->ignore
    }
  }
  let onConfirm = passphrase => {
    setLoading(_ => true)
    AccountUtils.restoreAccounts(
      ~mnemonic=backupPhrase->formatForMnemonic,
      ~passphrase,
      ~onDone=accounts => {
        switch accounts {
        | Ok(accounts) => handleAccounts(accounts, passphrase)
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
