open RestoreAndSave
module Display = {
  @react.component
  let make = (~qrPayload: SecretQRPayload.t) => {
    let restoreAndSave = useRestoreAndSave()
    let (loading, setLoading) = React.useState(_ => false)
    let notify = SnackBar.useNotification()
    <>
      <PollyfillCrypto />
      <InstructionsContainer
        title="Import secret from desktop"
        instructions="Enter your Umami Desktop password. This password will be kept on mobile.">
        <PasswordConfirm.Plain
          loading
          onSubmit={password => {
            setLoading(_ => true)
            let {recoveryPhrase, derivationPath} = qrPayload
            let {data, iv, salt} = recoveryPhrase
            AESGCM.decrypt(~data, ~iv, ~salt, ~password)
            // Pass derivationPath as parameter since it could be custom
            ->Promise.then(seedPhrase =>
              restoreAndSave(~seedPhrase, ~password, ~derivationPath, ())
            )
            ->Promise.catch(exn => {
              notify("Failed to decrypt desktop QR code. " ++ exn->Helpers.getMessage)
              Promise.resolve()
            })
            ->Promise.finally(_ => setLoading(_ => false))
            ->ignore
          }}
        />
      </InstructionsContainer>
    </>
  }
}

@react.component
let make = (~navigation as _, ~route: NavStacks.OffBoard.route) =>
  route->NavUtils.getDesktopSeedPhrase->Helpers.reactFold(qrPayload => <Display qrPayload />)
