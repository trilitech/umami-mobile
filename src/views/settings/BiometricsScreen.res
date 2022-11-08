let useKeychainStorage = () => {
  let (_, setBio) = Store.useBiometricsEnabled()

  (password: option<string>) =>
    switch password {
    | None =>
      KeychainUtils.resetPassword()->Promise.thenResolve(() => {
        setBio(_ => false)
      })
    | Some(password) =>
      RestoreAndSave.passwordIsValid(password)->Promise.then(_ =>
        KeychainUtils.setPassword(password)->Promise.thenResolve(_ => setBio(_ => true))
      )
    }
}

open CommonComponents
module Display = {
  @react.component
  let make = (~supportedBiometric: Js.Nullable.t<string>) => {
    let (bio, _) = Store.useBiometricsEnabled()
    let (step, setStep) = React.useState(_ => #display)
    let notify = SnackBar.useNotification()

    let changeKeychainPassword = useKeychainStorage()
    let text = supportedBiometric->Js.Nullable.toOption->Belt.Option.getWithDefault("Very unsafe!")

    let el =
      <Container>
        <InstructionsPanel
          title="Biometrics" instructions="Enable biometrics (requires password)"
        />
        <Wrapper style={StyleUtils.makeMargin()} justifyContent=#spaceBetween>
          <Paper.Text> {`Biometrics ${text}`->React.string} </Paper.Text>
          <Paper.Switch
            onValueChange={_ =>
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
              }}
            value=bio
          />
        </Wrapper>
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
}

@react.component
let make = (~navigation as _, ~route as _) => {
  let queryResult: ReactQuery.queryResult<exn, _> = ReactQuery.useQuery(
    ReactQuery.queryOptions(
      ~queryFn=_ => Keychain.getSupportedBiometryType(),
      ~queryKey="biometricType",
      ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
      (),
    ),
  )

  open Paper
  if queryResult.isLoading {
    <Text> {"loading"->React.string} </Text>
  } else if queryResult.isError {
    <Text> {"error"->React.string} </Text>
  } else {
    queryResult.data->Helpers.reactFold(supportedBiometric => <Display supportedBiometric />)
  }
}
