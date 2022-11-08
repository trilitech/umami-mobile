open Belt

module Display = {
  @react.component
  let make = (~renderForm, ~renderSignedData, ~sign, ~notify) => {
    let (content, setContent) = React.useState(_ => "")
    let (loading, setLoading) = React.useState(_ => false)
    let (signed, setSigned) = React.useState(_ => None)

    let (step, setStep) = React.useState(_ => #fillForm)

    let (biometricsEnabled, _) = Store.useBiometricsEnabled()

    let handleSubmit = (password, content) => {
      setLoading(_ => true)
      sign(~content, ~password)
      ->Promise.thenResolve(signed => {
        setSigned(_ => Some(signed))
      })
      ->Promise.catch(exn => {
        notify("Failed to sign! " ++ Helpers.getMessage(exn))
        Promise.resolve()
      })
      ->Promise.finally(_ => {
        setLoading(_ => false)
      })
      ->ignore
    }

    let form = renderForm(~onSubmit=content => {
      if biometricsEnabled {
        KeychainUtils.getPassword()
        ->Promise.thenResolve(password =>
          password->Belt.Option.map(password => handleSubmit(password, content))
        )
        ->ignore
      } else {
        setContent(_ => content)
        setStep(_ => #enterPassword)
      }
    })

    let el = switch step {
    | #fillForm => form
    | #enterPassword => <>
        <InstructionsPanel
          title="Signature" instructions="Please enter your wallet password to sign your data"
        />
        <Container>
          <PasswordConfirm.Plain loading onSubmit={p => handleSubmit(p, content)} />
        </Container>
      </>
    }
    {signed->Option.mapWithDefault(el, renderSignedData)}
  }
}

@react.component
let make = (~renderForm, ~renderSignedData=signed => <SignedDataDisplay signed />) => {
  let sign = SignUtils.useSign()
  let notify = SnackBar.useNotification()
  sign->Helpers.reactFold(sign => <Display sign notify renderForm renderSignedData />)
}
