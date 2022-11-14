let useKeychainStorage = () => {
  let (_, setBio) = Store.useBiometricsEnabled()

  (password: option<string>) =>
    switch password {
    | None =>
      KeychainUtils.resetPassword()->Promise.thenResolve(() => {
        setBio(_ => false)
      })
    | Some(password) =>
      BackupPhraseStorage.validatePassword(password)->Promise.then(_ =>
        KeychainUtils.setPassword(password)->Promise.thenResolve(_ => setBio(_ => true))
      )
    }
}

let useBiometricType = () => {
  let queryResult: ReactQuery.queryResult<exn, _> = ReactQuery.useQuery(
    ReactQuery.queryOptions(
      ~queryFn=_ => Keychain.getSupportedBiometryType(),
      ~queryKey="biometricType",
      ~refetchOnWindowFocus=ReactQuery.refetchOnWindowFocus(#bool(false)),
      (),
    ),
  )

  queryResult
}

open CommonComponents
open Paper
module BiometricsSwitch = {
  @react.component
  let make = (~onChange, ~biometricsEnabled) => {
    let {data, isError} = useBiometricType()

    if isError {
      <Text> {"error"->React.string} </Text>
    } else {
      data->Helpers.reactFold(supportedBiometric => {
        let text =
          supportedBiometric->Js.Nullable.toOption->Belt.Option.getWithDefault("Very unsafe!")
        <Wrapper style={StyleUtils.makeMargin()} justifyContent=#spaceBetween>
          <Paper.Text> {`Biometrics ${text}`->React.string} </Paper.Text>
          <Paper.Switch onValueChange={onChange} value=biometricsEnabled />
        </Wrapper>
      })
    }
  }
}
