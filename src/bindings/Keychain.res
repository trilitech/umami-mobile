type accessControl = [#BiometryCurrentSetOrDevicePasscode | #BiometryAnyOrDevicePasscode]

let falseToNull: 'a => 'a = %raw("v => v === false ? null : v")
@module("react-native-keychain")
external getGenericPasswordRaw: unit => Promise.t<
  Js.Nullable.t<{
    "username": string,
    "password": string,
  }>,
> = "getGenericPassword"

let getGenericPassword = () => getGenericPasswordRaw()->Promise.thenResolve(falseToNull)

@module("react-native-keychain")
external setGenericPassword: (
  ~username: string,
  ~password: string,
  ~options: {"accessControl": accessControl},
) => Promise.t<unit> = "setGenericPassword"

@module("react-native-keychain")
external getSupportedBiometryType: unit => Promise.t<Js.Nullable.t<string>> =
  "getSupportedBiometryType"

@module("react-native-keychain")
external resetGenericPassword: unit => Promise.t<bool> = "resetGenericPassword"
