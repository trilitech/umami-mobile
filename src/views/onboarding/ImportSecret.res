open Paper

let backupPharseIsValid = (s: string) =>
  s->Js.String2.trim->Js.String2.split(" ")->Array.length == 24

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
        disabled={!backupPharseIsValid(backupPhrase)}
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

  let (loading, setLoading) = React.useState(_ => false)
  let hoc = (~onSubmit) => <ImportSecret backupPhrase setBackupPhrase onSubmit />

  let handleAccounts = (accounts: array<Store.account>, passphrase) => {
    BackupphraseCrypto.encrypt(backupPhrase, passphrase)
    ->Promise.thenResolve(_ => {
      setAccounts(_ => accounts)
    })
    ->ignore
  }
  let onConfirm = passphrase => {
    setLoading(_ => true)
    AccountUtils.restoreAccounts(
      ~mnemonic=backupPhrase,
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
