@react.component
let make = (~navigation as _, ~route as _) => {
  let (bio, _) = Store.useBiometricsEnabled()
  let (step, setStep) = React.useState(_ => #display)
  let notify = SnackBar.useNotification()

  let changeKeychainPassword = Biometrics.useKeychainStorage()
  let handleChange = () => {
    if !bio {
      setStep(_ => #enterPassword)
    } else {
      changeKeychainPassword(None)
      ->Promise.thenResolve(_ => {
        notify("Biometrics disabled")
      })
      ->Promise.catch(exn => {
        notify("Failed to toggle biometrics. " ++ Helpers.getMessage(exn))
        Promise.resolve()
      })
      ->ignore
    }
  }

  let el =
    <Container>
      <InstructionsPanel title="Biometrics" instructions="Enable biometrics (requires password)" />
      <Biometrics.BiometricsSwitch onChange={_ => handleChange()} biometricsEnabled=bio />
    </Container>

  let password =
    <Container>
      <InstructionsPanel
        title="Enter password" instructions="enter password to enable biometrics"
      />
      <PasswordConfirm.Plain
        onSubmit={password => {
          changeKeychainPassword(password->Some)
          ->Promise.thenResolve(_ => {
            notify("Biometrics enabled")
            setStep(_ => #display)
          })
          ->Promise.catch(exn => {
            exn->Helpers.getMessage->notify
            Promise.resolve()
          })
          ->ignore
        }}
      />
    </Container>

  switch step {
  | #display => el
  | #enterPassword => password
  }
}
