open RestoreAndSave
@react.component
let make = (~navigation as _, ~route as _) => {
  let notify = SnackBar.useNotification()

  let (mnemonic, _) = DangerousMnemonicHooks.useMnemonic()

  let (loading, setLoading) = React.useState(_ => false)
  let restoreAndSave = useRestoreAndSave()

  let handlePasswordSubmit = data => {
    let password = data["password"]
    let saveInKeychain = data["saveInKeyChain"]
    setLoading(_ => true)
    let mnemonic = mnemonic->Js.Array2.joinWith(" ")

    restoreAndSave(
      ~derivationPath=DerivationPath.default,
      ~password,
      ~seedPhrase=mnemonic,
      ~saveInKeychain,
      (),
    )
    ->Promise.catch(exn => {
      setLoading(_ => false)
      notify("Failed to generate account. " ++ exn->Helpers.getMessage)
      Promise.resolve()
    })
    ->ignore
  }

  <>
    <InstructionsPanel
      step="Step 3 of 4"
      title="Set a password to secure your wallet"
      instructions="Please note that this password is not recorded anywhere and only applies to this machine."
    />
    <Container> <PasswordCreate loading onSubmit={handlePasswordSubmit} /> </Container>
  </>
}
