let usePasswordConfirm = (~hoc, ~onConfirm, ~loading=false, ~creation=false, ()) => {
  let (step, setStep) = React.useState(_ => #fill)
  let el: React.element = hoc(~onSubmit=_ => setStep(_ => #confirm))

  switch step {
  | #fill => el
  | #confirm =>
    creation
      ? <>
          <InstructionsPanel
            title="Set a password to secure your wallet"
            instructions="Please note that this password is not recorded anywhere and only applies to this machine."
          />
          <Container> <PasswordCreate loading onSubmit=onConfirm /> </Container>
        </>
      : <PasswordConfirm loading onSubmit=onConfirm />
  }
}
