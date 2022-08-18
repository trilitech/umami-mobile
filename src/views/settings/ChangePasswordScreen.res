let changePassword = (oldPassword, newPassword) =>
  BackupPhraseStorage.load(oldPassword)->Promise.then(mnemonic =>
    BackupPhraseStorage.save(mnemonic, newPassword)
  )

@react.component
let make = (~navigation as _, ~route as _) => {
  let (oldPassword, setOldPassword) = EphemeralState.useEphemeralState(None)
  let notify = SnackBar.useNotification()
  let goBack = NavUtils.useGoBack()
  let handleSubmitOld = password => setOldPassword(_ => Some(password))

  let handleSubmitNew = (oldPassword, newPassword) =>
    changePassword(oldPassword, newPassword)
    ->Promise.thenResolve(_ => {
      goBack()
      notify("Password changed!")
    })
    ->Promise.catch(exn => {
      exn->Helpers.getMessage->notify
      Promise.resolve()
    })
    ->ignore

  <Container>
    {switch oldPassword {
    | None => <PasswordConfirm onSubmit=handleSubmitOld />
    | Some(oldPassword) =>
      <PasswordCreate onSubmit={newPassword => handleSubmitNew(oldPassword, newPassword)} />
    }}
  </Container>
}
