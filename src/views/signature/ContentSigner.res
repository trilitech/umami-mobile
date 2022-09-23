open Belt

module PureContentSigner = {
  @react.component
  let make = (~renderForm, ~renderSignedData, ~sign, ~notify) => {
    let (content, setContent) = React.useState(_ => "")
    let (loading, setLoading) = React.useState(_ => false)
    let (signed, setSigned) = React.useState(_ => None)

    let (step, setStep) = React.useState(_ => #fillForm)

    let form = renderForm(content => {
      setContent(_ => content)
      setStep(_ => #enterPassword)
    })

    let el = switch step {
    | #fillForm => form
    | #enterPassword => <>
        <InstructionsPanel
          title="Signature" instructions="Please enter your wallet password to sign your data"
        />
        <Container>
          <PasswordConfirm.Plain
            loading
            onSubmit={password => {
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
            }}
          />
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
  sign->Helpers.reactFold(sign => <PureContentSigner sign notify renderForm renderSignedData />)
}
