let usePasswordConfirm = (~hoc, ~onConfirm, ~loading=false, ~creation=false, ()) => {
  let (step, setStep) = React.useState(_ => #fill)
  let el: React.element = hoc(~onSubmit=_ => setStep(_ => #confirm))

  switch step {
  | #fill => el
  | #confirm =>
    creation
      ? <PasswordCreate loading onSubmit=onConfirm />
      : <PasswordConfirm loading onSubmit=onConfirm />
  }
}
