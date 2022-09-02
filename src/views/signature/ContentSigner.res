open Belt

open Paper
module SignedDataDisplay = {
  open CommonComponents
  open SignedData
  @react.component
  let make = (~signed) => {
    <Wrapper flexDirection=#column alignItems=#center>
      <Headline> {React.string("Your signed data")} </Headline>
      <Text> {("Signer " ++ signed.pk->Pkh.buildFromPk->Pkh.toPretty)->React.string} </Text>
      <Text style={StyleUtils.makeVMargin()}> {signed.content->React.string} </Text>
      <Qr value={signed->SignedData.serialise} size=260 />
    </Wrapper>
  }
}

@react.component
let make = (~sign, ~notify, ~renderForm) => {
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
              // notify("Signed")
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
  {signed->Option.mapWithDefault(el, signed => <SignedDataDisplay signed />)}
}
