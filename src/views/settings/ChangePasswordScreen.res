let useChangePassword = () => {
  let restoreAndSave = RestoreAndSave.useRestoreAndSave()
  (oldPassword, newPassword) => {
    BackupPhraseStorage.load(oldPassword)->Promise.then(seedPhrase => {
      restoreAndSave(
        ~password=newPassword,
        ~derivationPath=DerivationPath.default,
        ~seedPhrase,
        (),
      )->Promise.then(() => {
        BackupPhraseStorage.save(seedPhrase, newPassword)
      })
    })
  }
}

let useUpdateKeychainIfBioEnabled = () => {
  let (bio, _) = Store.useBiometricsEnabled()
  let setPassword = BiometricsScreen.useKeychainStorage()

  password => {
    if bio {
      setPassword(Some(password))
    } else {
      Promise.resolve()
    }
  }
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let (oldPassword, setOldPassword) = EphemeralState.useEphemeralState(None)
  let (loading, setLoading) = React.useState(_ => false)
  let notify = SnackBar.useNotification()
  let goBack = NavUtils.useGoBack()
  let updateKeychain = useUpdateKeychainIfBioEnabled()

  let handleSubmitOld = password =>
    RestoreAndSave.passwordIsValid(password)
    ->Promise.thenResolve(_ => {
      setOldPassword(_ => Some(password))
    })
    ->Promise.catch(exn => {
      notify(exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore

  let changePassword = useChangePassword()
  let handleSubmitNew = (oldPassword, newPassword) => {
    setLoading(_ => true)
    changePassword(oldPassword, newPassword)
    ->Promise.then(_ => updateKeychain(newPassword))
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
      <PasswordCreate loading onSubmit={newPassword => handleSubmitNew(oldPassword, newPassword)} />
    }}
  </Container>
}
