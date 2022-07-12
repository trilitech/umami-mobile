@react.component
let make = (~navigation as _, ~route as _) => {
  let (dangerouseStorage, setDangerousStorage) = EphemeralState.useEphemeralState([])
  let goBack = NavUtils.useGoBack()
  let notify = SnackBar.useNotification()

  <Container>
    {if dangerouseStorage == [] {
      <PasswordConfirm
        onSubmit={password => {
          BackupPhraseStorage.load(password)
          ->Promise.thenResolve(mnemonic =>
            setDangerousStorage(_ => mnemonic->Js.String2.split(" "))
          )
          ->Promise.catch(exn => {
            notify(`Failed to load backup phrase. Reason: ${exn->Helpers.getMessage}`)
            Promise.resolve()
          })
          ->ignore
          ()
        }}
      />
    } else {
      <>
        <InstructionsPanel title="This is your backup phrase" instructions="Write it down now!" />
        <Mnemonic mnemonic=dangerouseStorage />
        <ContinueBtn onPress={_ => {goBack()}} text="Close me fast!" />
      </>
    }}
  </Container>
}
