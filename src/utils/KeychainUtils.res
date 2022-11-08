let getPassword = () =>
  Keychain.getGenericPassword()->Promise.thenResolve(res =>
    res->Js.Nullable.toOption->Belt.Option.map(res => res["password"])
  )

let setPassword = password =>
  Keychain.setGenericPassword(
    ~username="master",
    ~password,
    ~options={"accessControl": #BiometryAnyOrDevicePasscode},
  )

let resetPassword = () =>
  Keychain.resetGenericPassword()->Promise.then(res =>
    if res {
      Promise.resolve()
    } else {
      Js.Exn.raiseError("Failed to reset passord")
    }
  )
