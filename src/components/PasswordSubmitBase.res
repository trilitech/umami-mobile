open Paper
module type Deps = {
  let getKeychainPassword: unit => Promise.t<option<string>>
}

module Make = (M: Deps) => {
  let getPassword = M.getKeychainPassword

  module Display = {
    @react.component
    let make = (
      ~biometricsEnabled,
      ~onSubmit: string => unit,
      ~onError=_ => (),
      ~loading=false,
      ~label="Submit",
    ) => {
      if biometricsEnabled {
        <Button
          mode=#contained
          loading
          onPress={_ => {
            getPassword()
            ->Promise.thenResolve(p => p->Belt.Option.map(onSubmit)->ignore)
            ->Promise.catch(exn => {
              onError(exn)
              Promise.resolve()
            })
            ->ignore
          }}>
          {label->React.string}
        </Button>
      } else {
        <PasswordConfirm.Plain onSubmit loading label />
      }
    }
  }

  @react.component
  let make = (~onSubmit, ~loading, ~label=?) => {
    let (biometricsEnabled, _) = Store.useBiometricsEnabled()
    <Display ?label biometricsEnabled onSubmit loading />
  }
}
