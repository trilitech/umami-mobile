@react.component
let make = (~navigation as _, ~route as _) => {
  let (dangerouseStorage, setDangerousStorage) = EphemeralState.useEphemeralState([])
  let goBack = NavUtils.useGoBack()
  let notify = SnackBar.useNotification()
  let (loading, setLoding) = React.useState(_ => false)

  <Container>
    {if dangerouseStorage == [] {
      <>
        <InstructionsPanel instructions="Authenticate to unlock backupphrase" />
        <PasswordSubmit
          label="Authenticate"
          loading
          onSubmit={password => {
            setLoding(_ => true)
            BackupPhraseStorage.load(password)
            ->Promise.thenResolve(mnemonic => {
              setLoding(_ => false)
              setDangerousStorage(_ => mnemonic->Js.String2.split(" "))
            })
            ->Promise.catch(exn => {
              notify(`Failed to load backup phrase. Reason: ${exn->Helpers.getMessage}`)
              setLoding(_ => false)
              Promise.resolve()
            })
            ->ignore
          }}
        />
      </>
    } else {
      <>
        <InstructionsPanel title="This is your backup phrase" instructions="Write it down now!" />
        <Mnemonic mnemonic=dangerouseStorage />
        <ContinueBtn onPress={_ => {goBack()}} text="Close me fast!" />
      </>
    }}
  </Container>
}
