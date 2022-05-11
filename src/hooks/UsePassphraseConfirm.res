let usePassphraseConfirm = (~hoc, ~onConfirm, ~isLoading=false, ~creation=false, ()) => {
  let (step, setStep) = React.useState(_ => #fill)
  let el: React.element = hoc(~onSubmit=_ => setStep(_ => #confirm))

  switch step {
  | #fill => el
  | #confirm =>
    creation
      ? <PasswordCreate loading=isLoading onSubmit=onConfirm />
      : <PasswordConfirm loading=isLoading onSubmit=onConfirm />
  }
}
