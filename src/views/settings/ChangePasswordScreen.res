let useChangePassword = () => {
  let restoreAndSave = RestoreAndSave.useRestoreAndSave()
  (oldPassword, newPassword, saveInKeychain) =>
    BackupPhraseStorage.load(oldPassword)->Promise.then(seedPhrase =>
      restoreAndSave(
        ~password=newPassword,
        ~derivationPath=DerivationPath.default,
        ~seedPhrase,
        ~saveInKeychain,
        (),
      )
    )
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let (oldPassword, setOldPassword) = EphemeralState.useEphemeralState(None)
  let (loading, setLoading) = React.useState(_ => false)
  let notify = SnackBar.useNotification()
  let goBack = NavUtils.useGoBack()

  let handleSubmitOld = password =>
    BackupPhraseStorage.validatePassword(password)
    ->Promise.thenResolve(_ => {
      setOldPassword(_ => Some(password))
    })
    ->Promise.catch(exn => {
      notify(exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore

  let changePassword = useChangePassword()

  let handleSubmitNew = (oldPassword, newPassword, saveInKeyChain) => {
    setLoading(_ => true)
    changePassword(oldPassword, newPassword, saveInKeyChain)
    ->Promise.thenResolve(_ => {
      setLoading(_ => false)
      goBack()
      notify("Password changed!")
    })
    ->Promise.catch(exn => {
      setLoading(_ => false)
      exn->Helpers.getMessage->notify
      Promise.resolve()
    })
    ->ignore
  }

  <Container>
    {switch oldPassword {
    | None => <PasswordConfirm onSubmit=handleSubmitOld />
    | Some(oldPassword) =>
      <PasswordCreate
        loading
        onSubmit={data => handleSubmitNew(oldPassword, data["password"], data["saveInKeyChain"])}
      />
    }}
  </Container>
}
